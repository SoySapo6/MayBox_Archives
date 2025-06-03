#!/bin/bash

# MayPoint - Lenguaje de Programación para APIs Web
# Instalador y Compilador Automático
# Versión 1.0

echo "🚀 Bienvenido a MayPoint - El lenguaje fácil para APIs"
echo "=================================================="

# Detectar sistema operativo
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v termux-setup-storage &> /dev/null; then
            OS="termux"
        else
            OS="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        OS="windows"
    else
        OS="unknown"
    fi
    echo "📱 Sistema detectado: $OS"
}

# Instalar Node.js según el sistema
install_nodejs() {
    echo "🔍 Verificando Node.js..."
    
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        echo "✅ Node.js ya está instalado: $NODE_VERSION"
        return 0
    fi
    
    echo "📦 Instalando Node.js..."
    
    case $OS in
        "termux")
            pkg update && pkg install nodejs npm
            ;;
        "linux")
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt install -y nodejs npm
            elif command -v yum &> /dev/null; then
                sudo yum install -y nodejs npm
            elif command -v pacman &> /dev/null; then
                sudo pacman -S nodejs npm
            fi
            ;;
        "macos")
            if command -v brew &> /dev/null; then
                brew install node
            else
                echo "❌ Por favor instala Homebrew primero o Node.js manualmente"
                exit 1
            fi
            ;;
        "windows")
            echo "❌ En Windows, por favor descarga Node.js desde https://nodejs.org"
            exit 1
            ;;
        *)
            echo "❌ Sistema no soportado. Instala Node.js manualmente"
            exit 1
            ;;
    esac
}

# Crear estructura del proyecto
create_project_structure() {
    echo "📁 Creando estructura del proyecto..."
    
    mkdir -p maypoint-project/{src,dist,templates}
    cd maypoint-project
    
    # Crear package.json
    cat > package.json << 'EOF'
{
  "name": "maypoint-app",
  "version": "1.0.0",
  "description": "Aplicación generada con MayPoint",
  "main": "dist/server.js",
  "scripts": {
    "start": "node dist/server.js",
    "dev": "node dist/server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "body-parser": "^1.20.2"
  },
  "keywords": ["maypoint", "api", "web"],
  "author": "MayPoint Developer",
  "license": "MIT"
}
EOF

    echo "✅ package.json creado"
}

# Crear el compilador de MayPoint
create_compiler() {
    echo "🔧 Creando compilador MayPoint..."
    
    cat > maypoint-compiler.js << 'EOF'
const fs = require('fs');
const path = require('path');

class MayPointCompiler {
    constructor() {
        this.interfaces = [];
        this.endpoints = [];
    }

    compile(sourceCode) {
        console.log('🔄 Compilando código MayPoint...');
        
        // Limpiar comentarios
        const cleanCode = this.removeComments(sourceCode);
        
        // Parsear interfaces
        this.parseInterfaces(cleanCode);
        
        // Parsear endpoints
        this.parseEndpoints(cleanCode);
        
        // Generar archivos
        this.generateHTML();
        this.generateServer();
        
        console.log('✅ Compilación completada');
    }

    removeComments(code) {
        return code.replace(/<---[\s\S]*?--->/g, '');
    }

    parseInterfaces(code) {
        const interfaceRegex = /interfaz\s*{([\s\S]*?)}/g;
        let match;
        
        while ((match = interfaceRegex.exec(code)) !== null) {
            const interfaceContent = match[1];
            const interface_obj = {
                title: '',
                elements: []
            };
            
            // Extraer título
            const titleMatch = interfaceContent.match(/titulo\s*"([^"]+)"/);
            if (titleMatch) {
                interface_obj.title = titleMatch[1];
            }
            
            // Extraer botones
            const buttonRegex = /boton\s*"([^"]+)"\s*hace\s*{\s*llamarAPI\("([^"]+)"\)\s*}/g;
            let buttonMatch;
            
            while ((buttonMatch = buttonRegex.exec(interfaceContent)) !== null) {
                interface_obj.elements.push({
                    type: 'button',
                    text: buttonMatch[1],
                    action: buttonMatch[2]
                });
            }
            
            this.interfaces.push(interface_obj);
        }
    }

    parseEndpoints(code) {
        const endpointRegex = /endpoint\s*"([^"]+)"\s*metodo\s*(GET|POST|PUT|DELETE)(?:\/(\w+))?\s*{\s*responder\s*"([^"]+)"\s*}/g;
        let match;
        
        while ((match = endpointRegex.exec(code)) !== null) {
            this.endpoints.push({
                path: match[1],
                method: match[2] || 'GET',
                response: match[4]
            });
        }
    }

    generateHTML() {
        let buttonsHTML = '';
        
        this.interfaces.forEach(interface_obj => {
            interface_obj.elements.forEach(element => {
                if (element.type === 'button') {
                    buttonsHTML += `
                    <button onclick="callAPI('${element.action}')" class="maypoint-btn">
                        ${element.text}
                    </button>`;
                }
            });
        });

        const htmlContent = `
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${this.interfaces[0]?.title || 'MayPoint App'}</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: white;
        }
        
        .container {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }
        
        h1 {
            text-align: center;
            margin-bottom: 30px;
            font-size: 2.5em;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
        }
        
        .maypoint-btn {
            background: linear-gradient(45deg, #FF6B6B, #4ECDC4);
            border: none;
            padding: 15px 30px;
            font-size: 16px;
            border-radius: 50px;
            cursor: pointer;
            margin: 10px;
            color: white;
            font-weight: bold;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
        }
        
        .maypoint-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
        }
        
        #response {
            margin-top: 20px;
            padding: 20px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 10px;
            min-height: 50px;
            font-size: 18px;
        }
        
        .loading {
            opacity: 0.7;
            pointer-events: none;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>${this.interfaces[0]?.title || 'MayPoint App'}</h1>
        <div class="buttons-container">
            ${buttonsHTML}
        </div>
        <div id="response">
            <p>👋 ¡Hola! Presiona un botón para probar la API</p>
        </div>
    </div>

    <script>
        async function callAPI(endpoint) {
            const responseDiv = document.getElementById('response');
            responseDiv.innerHTML = '<p>⏳ Cargando...</p>';
            responseDiv.classList.add('loading');
            
            try {
                const response = await fetch(endpoint);
                const data = await response.text();
                responseDiv.innerHTML = '<p>' + data + '</p>';
            } catch (error) {
                responseDiv.innerHTML = '<p>❌ Error: ' + error.message + '</p>';
            } finally {
                responseDiv.classList.remove('loading');
            }
        }
    </script>
</body>
</html>`;

        fs.writeFileSync('dist/index.html', htmlContent);
        console.log('✅ Archivo HTML generado');
    }

    generateServer() {
        let routesCode = '';
        
        this.endpoints.forEach(endpoint => {
            const method = endpoint.method.toLowerCase();
            routesCode += `
app.${method}('${endpoint.path}', (req, res) => {
    res.send('${endpoint.response}');
});
`;
        });

        const serverContent = `
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Servir archivos estáticos
app.use(express.static(path.join(__dirname)));

// Ruta principal
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// Endpoints generados por MayPoint
${routesCode}

// Iniciar servidor
app.listen(PORT, () => {
    console.log('🚀 Servidor MayPoint ejecutándose en:');
    console.log('   Local:   http://localhost:' + PORT);
    console.log('   Red:     http://0.0.0.0:' + PORT);
    console.log('');
    console.log('📱 Presiona Ctrl+C para detener el servidor');
});
`;

        fs.writeFileSync('dist/server.js', serverContent);
        console.log('✅ Servidor Express generado');
    }
}

// Función principal
function compileMayPoint(filename) {
    if (!fs.existsSync(filename)) {
        console.error('❌ Archivo no encontrado:', filename);
        return;
    }
    
    const sourceCode = fs.readFileSync(filename, 'utf8');
    const compiler = new MayPointCompiler();
    compiler.compile(sourceCode);
}

// Exportar para uso externo
if (require.main === module) {
    const filename = process.argv[2];
    if (!filename) {
        console.error('❌ Uso: node maypoint-compiler.js archivo.may');
        process.exit(1);
    }
    compileMayPoint(filename);
}

module.exports = { MayPointCompiler, compileMayPoint };
EOF

    echo "✅ Compilador creado"
}

# Crear editor nano-like para MayPoint
create_editor() {
    echo "📝 Creando editor MayPoint..."
    
    cat > maypoint-editor.js << 'EOF'
const readline = require('readline');
const fs = require('fs');

class MayPointEditor {
    constructor() {
        this.lines = [];
        this.currentLine = 0;
        this.filename = '';
        this.modified = false;
    }

    start(filename) {
        this.filename = filename || 'app.may';
        
        // Cargar archivo si existe
        if (fs.existsSync(this.filename)) {
            const content = fs.readFileSync(this.filename, 'utf8');
            this.lines = content.split('\n');
        } else {
            // Plantilla por defecto
            this.lines = [
                '<--- Definir la interfaz (UI) --->',
                'interfaz {',
                '    titulo "Mi App MayPoint"',
                '    boton "Presióname" hace {',
                '        llamarAPI("/hola")',
                '    }',
                '}',
                '',
                '<--- Definir los endpoints --->',
                'endpoint "/hola" metodo GET {',
                '    responder "¡Hola, soy MayPoint! 👋"',
                '}',
                ''
            ];
        }
        
        this.showInterface();
    }

    showInterface() {
        console.clear();
        console.log('🎯 MayPoint Editor v1.0');
        console.log('Archivo:', this.filename, this.modified ? '(modificado)' : '');
        console.log('═'.repeat(60));
        
        this.lines.forEach((line, index) => {
            const marker = index === this.currentLine ? '►' : ' ';
            const lineNum = (index + 1).toString().padStart(3, ' ');
            console.log(`${marker}${lineNum}│ ${line}`);
        });
        
        console.log('═'.repeat(60));
        console.log('Comandos: [S]ave, [R]un, [Q]uit, [N]ew line, [D]elete line');
        
        this.waitForInput();
    }

    waitForInput() {
        const rl = readline.createInterface({
            input: process.stdin,
            output: process.stdout
        });

        rl.question('MayPoint> ', (input) => {
            rl.close();
            this.handleCommand(input.trim());
        });
    }

    handleCommand(input) {
        const command = input.toLowerCase();
        
        switch (command) {
            case 's':
            case 'save':
                this.save();
                break;
            case 'r':
            case 'run':
                this.run();
                break;
            case 'q':
            case 'quit':
                this.quit();
                break;
            case 'n':
            case 'new':
                this.newLine();
                break;
            case 'd':
            case 'delete':
                this.deleteLine();
                break;
            case 'up':
                this.moveCursor(-1);
                break;
            case 'down':
                this.moveCursor(1);
                break;
            default:
                if (input.length > 0) {
                    this.editLine(input);
                } else {
                    this.showInterface();
                }
        }
    }

    editLine(text) {
        this.lines[this.currentLine] = text;
        this.modified = true;
        this.showInterface();
    }

    newLine() {
        this.lines.splice(this.currentLine + 1, 0, '');
        this.currentLine++;
        this.modified = true;
        this.showInterface();
    }

    deleteLine() {
        if (this.lines.length > 1) {
            this.lines.splice(this.currentLine, 1);
            if (this.currentLine >= this.lines.length) {
                this.currentLine = this.lines.length - 1;
            }
            this.modified = true;
        }
        this.showInterface();
    }

    moveCursor(direction) {
        this.currentLine += direction;
        if (this.currentLine < 0) this.currentLine = 0;
        if (this.currentLine >= this.lines.length) this.currentLine = this.lines.length - 1;
        this.showInterface();
    }

    save() {
        fs.writeFileSync(this.filename, this.lines.join('\n'));
        this.modified = false;
        console.log('✅ Archivo guardado:', this.filename);
        setTimeout(() => this.showInterface(), 1000);
    }

    run() {
        if (this.modified) {
            this.save();
        }
        
        console.log('🚀 Compilando y ejecutando...');
        const { spawn } = require('child_process');
        
        // Compilar
        const compile = spawn('node', ['maypoint-compiler.js', this.filename]);
        
        compile.on('close', (code) => {
            if (code === 0) {
                console.log('✅ Compilación exitosa');
                
                // Instalar dependencias si es necesario
                if (!fs.existsSync('node_modules')) {
                    console.log('📦 Instalando dependencias...');
                    const npm = spawn('npm', ['install'], { stdio: 'inherit' });
                    
                    npm.on('close', () => {
                        this.startServer();
                    });
                } else {
                    this.startServer();
                }
            } else {
                console.log('❌ Error en la compilación');
                setTimeout(() => this.showInterface(), 2000);
            }
        });
    }

    startServer() {
        console.log('🌐 Iniciando servidor...');
        const server = spawn('node', ['dist/server.js'], { stdio: 'inherit' });
        
        // Esperar Ctrl+C para volver al editor
        process.on('SIGINT', () => {
            server.kill();
            setTimeout(() => this.showInterface(), 500);
        });
    }

    quit() {
        if (this.modified) {
            const rl = readline.createInterface({
                input: process.stdin,
                output: process.stdout
            });

            rl.question('¿Guardar cambios antes de salir? (s/n): ', (answer) => {
                rl.close();
                if (answer.toLowerCase() === 's') {
                    this.save();
                }
                console.log('👋 ¡Hasta luego!');
                process.exit(0);
            });
        } else {
            console.log('👋 ¡Hasta luego!');
            process.exit(0);
        }
    }
}

// Iniciar editor
const editor = new MayPointEditor();
const filename = process.argv[2];
editor.start(filename);
EOF

    echo "✅ Editor creado"
}

# Instalar dependencias
install_dependencies() {
    echo "📦 Instalando dependencias..."
    npm install
    echo "✅ Dependencias instaladas"
}

# Crear archivo de ejemplo
create_example() {
    cat > src/ejemplo.may << 'EOF'
<--- Ejemplo de aplicación MayPoint --->
<--- Este es un comentario --->

interfaz {
    titulo "Mi Primera App MayPoint"
    boton "Saludar" hace {
        llamarAPI("/saludo")
    }
    boton "Obtener Hora" hace {
        llamarAPI("/hora")
    }
}

<--- Definir endpoints de la API --->
endpoint "/saludo" metodo GET {
    responder "¡Hola desde MayPoint! 🚀"
}

endpoint "/hora" metodo GET {
    responder "La hora actual es: " + new Date().toLocaleString()
}
EOF

    echo "✅ Archivo de ejemplo creado en src/ejemplo.may"
}

# Función principal
main() {
    detect_os
    install_nodejs
    create_project_structure
    create_compiler
    create_editor
    install_dependencies
    create_example
    
    echo ""
    echo "🎉 ¡MayPoint instalado correctamente!"
    echo ""
    echo "📚 Cómo usar MayPoint:"
    echo "  1. Editar código:    node maypoint-editor.js [archivo.may]"
    echo "  2. Compilar:         node maypoint-compiler.js archivo.may"
    echo "  3. Ejecutar:         npm start"
    echo ""
    echo "🚀 Ejemplo rápido:"
    echo "  node maypoint-editor.js src/ejemplo.may"
    echo ""
    echo "💡 Dentro del editor:"
    echo "  - Escribe tu código MayPoint línea por línea"
    echo "  - Presiona 'S' para guardar"
    echo "  - Presiona 'R' para compilar y ejecutar"
    echo "  - Presiona 'Q' para salir"
    echo ""
    
}

# Ejecutar instalación
main

cd maypoint-project