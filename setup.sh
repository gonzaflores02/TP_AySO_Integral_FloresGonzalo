#!/bin/bash

# /etc/hosts
echo "192.168.56.5  VM1-Grupo-FloresGonzalo" | sudo tee -a /etc/hosts
echo "192.168.56.6  VM2-Grupo-FloresGonzalo" | sudo tee -a /etc/hosts

# SSH keygen
ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519

# Cruzar claves
ssh-copy-id vagrant@192.168.56.5
ssh-copy-id vagrant@192.168.56.6
