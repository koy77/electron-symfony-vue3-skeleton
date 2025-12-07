const { app, BrowserWindow, ipcMain, Menu } = require('electron')
const path = require('path')

// Determine if running in development mode
const isDev = process.argv.includes('--dev')

// Frontend URL - use dev server in development, built files in production
const FRONTEND_URL = isDev
    ? 'http://frontend:5173'
    : `file://${path.join(__dirname, 'dist/index.html')}`

let mainWindow

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 1400,
        height: 900,
        minWidth: 800,
        minHeight: 600,
        webPreferences: {
            preload: path.join(__dirname, 'preload.js'),
            nodeIntegration: false,
            contextIsolation: true,
            webSecurity: false, // Allow loading local resources in Docker
        },
        icon: path.join(__dirname, 'assets/icon.png'),
        show: false, // Don't show until ready
        titleBarStyle: process.platform === 'darwin' ? 'hiddenInset' : 'default',
    })

    // Load the frontend
    mainWindow.loadURL(FRONTEND_URL)

    // Show window when ready
    mainWindow.once('ready-to-show', () => {
        mainWindow.show()
        if (isDev) {
            mainWindow.webContents.openDevTools()
        }
    })

    mainWindow.on('closed', function () {
        mainWindow = null
    })

    // Handle navigation
    mainWindow.webContents.on('will-navigate', (event, navigationUrl) => {
        const parsedUrl = new URL(navigationUrl)
        
        // Allow navigation to frontend dev server and local files
        if (parsedUrl.origin === 'http://frontend:5173' || parsedUrl.protocol === 'file:') {
            return
        }
        
        // Block external navigation
        event.preventDefault()
    })
}

// Create application menu
function createMenu() {
    const template = [
        {
            label: 'File',
            submenu: [
                {
                    label: 'New Window',
                    accelerator: 'CmdOrCtrl+N',
                    click: () => createWindow()
                },
                { type: 'separator' },
                {
                    role: 'quit',
                    accelerator: 'CmdOrCtrl+Q'
                }
            ]
        },
        {
            label: 'View',
            submenu: [
                { role: 'reload' },
                { role: 'forceReload' },
                { type: 'separator' },
                { role: 'resetZoom' },
                { role: 'zoomIn' },
                { role: 'zoomOut' },
                { type: 'separator' },
                { role: 'togglefullscreen' },
                { type: 'separator' },
                { role: 'toggleDevTools' }
            ]
        },
        {
            label: 'Window',
            submenu: [
                { role: 'minimize' },
                { role: 'close' }
            ]
        }
    ]

    const menu = Menu.buildFromTemplate(template)
    Menu.setApplicationMenu(menu)
}

// App lifecycle
app.whenReady().then(() => {
    createWindow()
    createMenu()

    app.on('activate', function () {
        if (BrowserWindow.getAllWindows().length === 0) createWindow()
    })
})

app.on('window-all-closed', function () {
    if (process.platform !== 'darwin') app.quit()
})

// IPC Handlers
ipcMain.handle('get-app-version', () => {
    return app.getVersion()
})

ipcMain.handle('get-platform', () => {
    return process.platform
})

ipcMain.handle('get-app-info', () => {
    return {
        name: app.getName(),
        version: app.getVersion(),
        platform: process.platform,
        arch: process.arch,
        electronVersion: process.versions.electron,
        nodeVersion: process.versions.node,
        chromeVersion: process.versions.chrome
    }
})

// Window management
ipcMain.handle('minimize-window', () => {
    if (mainWindow) {
        mainWindow.minimize()
        return true
    }
    return false
})

ipcMain.handle('maximize-window', () => {
    if (mainWindow) {
        if (mainWindow.isMaximized()) {
            mainWindow.unmaximize()
            return false
        } else {
            mainWindow.maximize()
            return true
        }
    }
    return false
})

ipcMain.handle('close-window', () => {
    if (mainWindow) {
        mainWindow.close()
        return true
    }
    return false
})

// File system access
ipcMain.handle('read-file', async (event, filePath) => {
    const fs = require('fs').promises
    try {
        const data = await fs.readFile(filePath, 'utf-8')
        return { success: true, data }
    } catch (error) {
        return { success: false, error: error.message }
    }
})

ipcMain.handle('write-file', async (event, filePath, content) => {
    const fs = require('fs').promises
    try {
        await fs.writeFile(filePath, content, 'utf-8')
        return { success: true }
    } catch (error) {
        return { success: false, error: error.message }
    }
})

// System information
ipcMain.handle('get-system-info', async () => {
    const os = require('os')
    return {
        hostname: os.hostname(),
        platform: os.platform(),
        arch: os.arch(),
        release: os.release(),
        totalMemory: os.totalmem(),
        freeMemory: os.freemem(),
        cpus: os.cpus().length,
        uptime: os.uptime()
    }
})
