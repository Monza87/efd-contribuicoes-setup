#!/bin/bash

################################################################################
# Script de Instalação Automatizada
# EFD-Contribuições + XFCE + TightVNC
# 
# Uso: bash setup_efd_vnc_completo.sh
# 
# Este script instala tudo necessário para acessar o EFD-Contribuições
# remotamente via VNC em uma máquina Ubuntu 22.04
################################################################################

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir com cores
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Início do script
print_header "Instalação: EFD-Contribuições + XFCE + VNC"

# ============================================================================
# PASSO 1: Atualizar sistema
# ============================================================================
print_header "PASSO 1/5: Atualizando sistema"

print_info "Atualizando lista de pacotes..."
sudo apt-get update -qq

print_info "Instalando atualizações..."
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq

print_success "Sistema atualizado!"

# ============================================================================
# PASSO 2: Instalar XFCE (ambiente gráfico leve)
# ============================================================================
print_header "PASSO 2/5: Instalando XFCE"

print_info "Instalando XFCE4 e componentes..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    xfce4 \
    xfce4-goodies \
    xfce4-terminal \
    xfce4-panel \
    xfce4-session

print_success "XFCE instalado!"

# ============================================================================
# PASSO 3: Instalar TightVNC Server
# ============================================================================
print_header "PASSO 3/5: Instalando TightVNC Server"

print_info "Instalando TightVNC..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq tightvncserver

print_success "TightVNC instalado!"

# ============================================================================
# PASSO 4: Configurar VNC
# ============================================================================
print_header "PASSO 4/5: Configurando VNC"

print_info "Criando diretório ~/.vnc..."
mkdir -p ~/.vnc

print_info "Criando arquivo xstartup..."
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
EOF

chmod +x ~/.vnc/xstartup

print_info "Configurando senha VNC (padrão: 123456)..."
echo "123456" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

print_success "VNC configurado!"

# ============================================================================
# PASSO 5: Baixar e Instalar EFD-Contribuições
# ============================================================================
print_header "PASSO 5/5: Instalando EFD-Contribuições"

print_info "Criando diretório para instalação..."
mkdir -p ~/efd-contribuicoes
cd ~/efd-contribuicoes

print_info "Baixando EFD-Contribuições (150MB - pode levar alguns minutos)..."
wget -q --show-progress \
    "https://servicos.receita.fazenda.gov.br/publico/programas/SpedPisCofinsPVA/EFD-Contribuicoes_linux_x86_64-6.1.2.sh" \
    -O EFD-Contribuicoes_linux_x86_64-6.1.2.sh

print_info "Tornando instalador executável..."
chmod +x EFD-Contribuicoes_linux_x86_64-6.1.2.sh

print_info "Executando instalador (isso pode levar alguns minutos)..."
# Executar o instalador com respostas automáticas
./EFD-Contribuicoes_linux_x86_64-6.1.2.sh << 'INSTALLER_EOF'

o
o
o
y
o
n
o
INSTALLER_EOF

print_success "EFD-Contribuições instalado!"

# ============================================================================
# RESUMO FINAL
# ============================================================================
print_header "✓ INSTALAÇÃO CONCLUÍDA COM SUCESSO!"

echo ""
echo -e "${GREEN}Resumo da Instalação:${NC}"
echo "  • Sistema Operacional: Ubuntu 22.04"
echo "  • Ambiente Gráfico: XFCE4"
echo "  • Servidor VNC: TightVNC"
echo "  • EFD-Contribuições: v6.1.2"
echo ""

echo -e "${YELLOW}Próximos Passos:${NC}"
echo ""
echo "1. Iniciar o servidor VNC:"
echo "   ${BLUE}vncserver :1 -geometry 1280x1024 -depth 24${NC}"
echo ""
echo "2. Do seu computador, criar um SSH tunnel:"
echo "   ${BLUE}ssh -L 5901:localhost:5901 -i sua_chave.pem ubuntu@<IP_DA_INSTANCIA>${NC}"
echo ""
echo "3. Conectar via cliente VNC:"
echo "   ${BLUE}localhost:5901${NC}"
echo "   Senha: ${BLUE}123456${NC}"
echo ""
echo "4. Executar EFD-Contribuições:"
echo "   ${BLUE}/home/ubuntu/Programas/SPED-EFD-Contribuicoes/bin/efd-contribuicoes${NC}"
echo ""

echo -e "${YELLOW}Comandos Úteis:${NC}"
echo "  • Parar VNC: ${BLUE}vncserver -kill :1${NC}"
echo "  • Ver logs: ${BLUE}cat ~/.vnc/\$(hostname):1.log${NC}"
echo "  • Status VNC: ${BLUE}ps aux | grep vncserver${NC}"
echo ""

print_success "Tudo pronto! Divirta-se com o EFD-Contribuições! 🎉"
