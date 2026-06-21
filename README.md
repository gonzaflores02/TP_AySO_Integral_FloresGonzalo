# TP Integral - Arquitectura y Sistemas Operativos

Gonzalo Flores - Legajo 120581 - Division 313

El TP lo hice solo, asi que cumplo los 6 roles (R1 a R6). Por eso no use las ramas dev_R1 a dev_R6 que pide el enunciado, sino que use una sola rama dev para ir subiendo todo el desarrollo. Cuando terminaba una parte la mergeaba a main.

## Estructura

- vm/ -> Vagrantfile y scripts para levantar las 2 VMs
- LVM/ -> script de particionamiento y LVM
- Bash_script/ -> scripts de alta de usuarios y chequeo de URLs
- ansible/ -> playbook y roles
- docker/ -> dockerfile, docker-compose y la web
- setup.sh -> configura /etc/hosts y cruza las claves ssh entre las VMs

## Como levantar todo

Primero levantar las VMs:

cd vm/
vagrant up
vagrant ssh primero

El Vagrantfile ya clona este repositorio dentro de la VM en ~/repogit/TP_AySO_Integral_FloresGonzalo. Todos los comandos que siguen se ejecutan parado dentro de esa carpeta, salvo que se indique lo contrario:

cd ~/repogit/TP_AySO_Integral_FloresGonzalo

Despues correr el setup en cada VM:

bash setup.sh

Va a pedir confirmar la conexion SSH (escribir "yes") y la contraseña de cada VM (la clave es "vagrant"), una vez por cada VM.

### LVM

bash LVM/lvm.sh

Esto crea las particiones de tipo 8e, los PV, VG y LV pedidos:
vg_datos con lv_docker (10M) montado en /var/lib/docker/, lv_workareas (2.5G) montado en /work/
vg_temp con lv_swap (2.5G)
Y la swap tradicional de 1G en el disco que sobra.

Verificacion:

sudo pvs
sudo vgs
sudo lvs
df -h | grep mapper
swapon --show

### Bash Scripting

Parado dentro de Bash_script/alta_usuarios/ y Bash_script/check_url/ respectivamente:

cd Bash_script/alta_usuarios
bash alta_usuarios.sh Lista_Usuarios.txt vagrant

cd ../check_url
bash check_URL.sh Lista_URL.txt

Verificacion:

grep TP_202411 /etc/passwd
tree /tmp/head-check/
cat /var/log/status_url.log

### Ansible

cd ansible/
ansible-playbook -i inventory/hosts playbook.yml

Corre los 4 roles: TP_INI, Alta_Usuarios_FloresGonzalo, Sudoers_FloresGonzalo e Instala-tools_FloresGonzalo.

Nota: en la VM de Produccion (RedHat 9), los paquetes htop y tmux no se pueden instalar por falta de dependencias y disponibilidad en los repositorios de esa version. El rol usa ignore_errors para que el playbook no falle por esto. speedtest-cli si se instala bien en ambas distros.

Verificacion:

cat /tmp/Grupo/datos.txt
grep R1_Flores /etc/passwd
sudo cat /etc/sudoers.d/FloresGonzalo

### Docker

cd docker/
docker build -t tp-div_313_grupo_floresgonzalo .
docker compose up -d

Se puede ver entrando a 192.168.56.5:8081 desde el navegador.
La imagen esta subida en dockerhub como gonzaflores02/tp-div_313_grupo_floresgonzalo

Verificacion:

docker ps
curl localhost:8081

## Verificacion general

Todo el TP fue probado de punta a punta clonando el repo en una VM nueva y limpia, siguiendo estos mismos pasos, para confirmar que funciona sin depender de nada que ya estuviera configurado de antes.
