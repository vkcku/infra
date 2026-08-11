#!/usr/bin/env nu

# Wrapper for `mkpasswd` that prompts for a password twice to guard against typos.
def main [] {
    let first = (input --suppress-output "Password: ")
    print ""
    let second = (input --suppress-output "Password (again): ")
    print ""

    if $first != $second {
        print --stderr "Passwords do not match."
        exit 1
    }

    $first | mkpasswd -m sha512crypt --stdin
}
