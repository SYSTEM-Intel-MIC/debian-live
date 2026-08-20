#!/usr/bin/env python3
"""Patch only the Lindows build copy of ElevenDE's lock screen.

The setuid-root helper must authenticate the real session user.  LightDM can
preserve a stale USER environment variable during an autologin/session restart;
TTY authentication then succeeds while the graphical gate checks another
account.  Resolve the account from the real UID instead.
"""
from pathlib import Path
import sys

if len(sys.argv) != 2:
    raise SystemExit(f"usage: {sys.argv[0]} /path/to/shell/lock.c")

path = Path(sys.argv[1])
text = path.read_text()
old_include = '#include <crypt.h>\n'
new_include = old_include + '#include <security/pam_appl.h>\n'
if old_include not in text:
    raise SystemExit("lock.c crypt include marker not found")
if '#include <security/pam_appl.h>' not in text:
    text = text.replace(old_include, new_include, 1)

old_check = '''static int check_pw(const char *u, const char *p) {
    struct passwd *pe = getpwnam(u);
    if (!pe) return -1;
    const char *hash = pe->pw_passwd;
    if (!hash || !*hash) return 1;                   /* no password set */
    if (!strcmp(hash, "x") || !strcmp(hash, "*")) {
        struct spwd *sp = getspnam(u);
        if (sp && sp->sp_pwdp && *sp->sp_pwdp) hash = sp->sp_pwdp;
    }
    if (!hash || !*hash) return 1;
    if (hash[0] == '!' || hash[0] == '*') return 0;  /* locked account */
    char *c = crypt(p, hash);
    return (c && !strcmp(c, hash)) ? 1 : 0;
}
'''
new_check = '''static const char *lindows_pam_password;

static int lindows_pam_conversation(int n, const struct pam_message **msg,
                                     struct pam_response **resp, void *data) {
    (void)data;
    if (n <= 0 || n > 32 || !msg || !resp) return PAM_CONV_ERR;
    struct pam_response *answers = calloc((size_t)n, sizeof(*answers));
    if (!answers) return PAM_CONV_ERR;
    for (int i = 0; i < n; i++) {
        if (msg[i]->msg_style == PAM_PROMPT_ECHO_OFF) {
            answers[i].resp = strdup(lindows_pam_password ? lindows_pam_password : "");
            if (!answers[i].resp) {
                for (int j = 0; j <= i; j++) free(answers[j].resp);
                free(answers);
                return PAM_CONV_ERR;
            }
        } else if (msg[i]->msg_style == PAM_PROMPT_ECHO_ON) {
            answers[i].resp = strdup(user ? user : "");
            if (!answers[i].resp) {
                for (int j = 0; j <= i; j++) free(answers[j].resp);
                free(answers);
                return PAM_CONV_ERR;
            }
        } else if (msg[i]->msg_style != PAM_TEXT_INFO &&
                   msg[i]->msg_style != PAM_ERROR_MSG) {
            for (int j = 0; j <= i; j++) free(answers[j].resp);
            free(answers);
            return PAM_CONV_ERR;
        }
    }
    *resp = answers;
    return PAM_SUCCESS;
}

static int check_pw(const char *u, const char *p) {
    pam_handle_t *pamh = NULL;
    struct pam_conv conv = { lindows_pam_conversation, NULL };
    lindows_pam_password = p;
    int rc = pam_start("lightdm", u, &conv, &pamh);
    if (rc == PAM_SUCCESS)
        rc = pam_authenticate(pamh, PAM_SILENT);
    if (pamh) pam_end(pamh, rc);
    lindows_pam_password = NULL;
    return rc == PAM_SUCCESS ? 1 : 0;
}
'''
if old_check not in text:
    raise SystemExit("lock.c password check marker not found")
text = text.replace(old_check, new_check, 1)

old_user = '''    user = getenv("USER");
    if (!user || !*user) user = "kali";
'''
new_user = '''    /* LightDM may leave USER set to a previous/autologin account.  The
     * real UID is authoritative for the graphical session, including when
     * this helper is installed setuid-root. */
    struct passwd *session_pw = getpwuid(getuid());
    user = session_pw ? session_pw->pw_name : getenv("USER");
    if (!user || !*user) user = "kali";
'''
if old_user not in text:
    raise SystemExit("lock.c user-resolution marker not found")
text = text.replace(old_user, new_user, 1)
path.write_text(text)
print(f"patched {path}")
