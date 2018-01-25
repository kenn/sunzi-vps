# Sunzi VPS

sunzi-vps is a simple command line utility to create and/or destroy VPS instances interactively.

Works with [Linode](https://www.linode.com/), [DigitalOcean](https://www.digitalocean.com/) and [Vultr](https://www.vultr.com/)

It works as a plugin for [sunzi](https://github.com/kenn/sunzi), but can be used as a standalone tool.

![Sunzi for Linode](http://farm8.staticflickr.com/7210/6783789868_ab89010d5c.jpg)

## Quick start

Install:

```bash
$ gem install sunzi-vps
```

## Commands

```bash
$ sunzi vps         # Show command help
$ sunzi vps init    # Generate VPS config file
$ sunzi vps up      # Set up a new instance
$ sunzi vps down    # Tear down an existing instance
```
