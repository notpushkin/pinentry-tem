# pinentry-tem

A barebones pinentry for macOS using Touch ID and Keychain.

Build it:
```sh
swiftc main.swift -o ~/.local/bin/pinentry-tem
```

Save your key passphrase to Keychain:
```
$ pinentry-tem
OK hOI! welcom to... da TEM SHOP!!!
setpass
OK tem set password to 'SUPERSECURE'!!! (change it using Keychain Access)
```

Set GnuPG pinentry program:
```sh
echo "pinentry-program ${HOME}/.local/bin/pinentry-tem" >> ~/.gnupg/gpg-agent.conf
# or replace the existing entry
```

Reload the agent and check that everything works:
```sh
gpg-connect-agent reloadagent /bye
echo 'hOI!' | gpg -as
```
