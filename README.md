# Bdk Swift Sample app


| home                                                                                                     | send                                                                                                  |
| -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| ![](https://github.com/AMazkun/BdkSwiftSample/blob/main/Screenshot30.png) | ![](https://github.com/AMazkun/BdkSwiftSample/blob/main/Screenshot18.png) |

This project is an example app / testbed for `bdk` (Bitcoin Dev Kit) Swift bindings. Features include syncing to testnet, sending and receiving fake Bitcoin, and QR code scanning. It started out life as a hackathon project by @futurepaul and @konjoinfinity.

The basic logic has been mostly borrowed from the bdk-ffi sample app by @artfuldev.

Bdk Swift Sample App is strongly inspired by @thunderbiscuit's [Bitcoindevkit Android Demo Wallet](https://github.com/thunderbiscuit/bitcoindevkit-android-sample-app) with the primary differences being the choice of color scheme and operating system.

Check these out:
 - [bdk (where it all begins!)](https://github.com/bitcoindevkit/bdk)
 - [bdk-ffi](https://github.com/bitcoindevkit/bdk-ffi)
 - [bdk-swift](https://github.com/bitcoindevkit/bdk-swift)

#Updated: 09/14/2023
See screenshots

Features:
- completed Create new Wallet by Mnemonic generated
- completing restoring old Wallet with Mnemonic
- coping own Wallet address
- estimating fee for transaction (it's very depends on traffic, but just for fun)

Improvements:
- update balance after sending coins
- new input data validation algorithm in send task
- showing last operation fee and hash
- print changed to debugprint (that works)

Known Issues:
- example Mnemonic cause CRC error, not changed, but adding restoring old Wallet by Descriptor

Useful (receive test coins for your Wallet btc-testnet):
https://coinfaucet.eu/en/btc-testnet/
