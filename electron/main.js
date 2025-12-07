const { app, BrowserWindow, ipcMain, Menu, dialog, shell } = require('electron')
const path = require('path')
const fs = require('fs').promises

// Determine if running in development mode
const isDev = process.argv.includes('--dev') || process.env.ELECTRON_IS_DEV === '1'

// Frontend URL - use dev server in development, built files in production
const FRONTEND_URL = isDev
    ? 'http://frontend:5173'
    : `file://${path.join(__dirname, 'dist/index.html')}`

let mainWindow
let appWindows = []

function createWindow() {
    // Create browser window
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
            enableRemoteModule: false,
            sandbox: false
        },
        icon: path.join(__dirname, 'assets/icon.png'),
        show: false, // Don't show until ready
        titleBarStyle: process.platform === 'darwin' ? 'hiddenInset' : 'default',
        frame: true,
        backgroundColor: '#1a1a1a'
    })

    // Load frontend with error handling
    console.log(`Loading frontend from: ${FRONTEND_URL}`)
    mainWindow.loadURL(FRONTEND_URL).catch(err => {
        console.error('Failed to load frontend:', err)
        // Fallback to error page
        mainWindow.loadURL('data:text/html,<html><body><h1>Failed to load frontend</h1><p>Please ensure frontend service is running.</p></body></html>')
    })

    // Show window when ready
    mainWindow.once('ready-to-show', () => {
        mainWindow.show()
        if (isDev) {
            mainWindow.webContents.openDevTools()
        }
    })

    // Handle window closed
    mainWindow.on('closed', () => {
        mainWindow = null
    })

    // Handle navigation
    mainWindow.webContents.on('will-navigate', (event, navigationUrl) => {
        const parsedUrl = new URL(navigationUrl)
        
        // Allow navigation to frontend dev server and local files
        if (parsedUrl.origin === 'http://frontend:5173' || parsedUrl.protocol === 'file:') {
            return
        }
        
        // Open external links in default browser
        if (parsedUrl.protocol === 'http:' || parsedUrl.protocol === 'https:') {
            event.preventDefault()
            shell.openExternal(navigationUrl)
            return
        }
        
        // Block other navigation
        event.preventDefault()
    })

    // Handle new window creation
    mainWindow.webContents.setWindowOpenHandler(({ url }) => {
        shell.openExternal(url)
        return { action: 'deny' }
    })

    // Add to windows list
    appWindows.push(mainWindow)

    return mainWindow
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
                    label: 'Open Project Folder',
                    accelerator: 'CmdOrCtrl+O',
                    click: async () => {
                        const result = await dialog.showOpenDialog(mainWindow, {
                            properties: ['openDirectory'],
                            title: 'Select Project Folder'
                        })
                        if (!result.canceled && result.filePaths.length > 0) {
                            mainWindow.webContents.send('folder-selected', result.filePaths[0])
                        }
                    }
                },
                { type: 'separator' },
                {
                    role: 'quit',
                    accelerator: 'CmdOrCtrl+Q'
                }
            ]
        },
        {
            label: 'Edit',
            submenu: [
                { role: 'undo' },
                { role: 'redo' },
                { type: 'separator' },
                { role: 'cut' },
                { role: 'copy' },
                { role: 'paste' },
                { role: 'selectall' }
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
        },
        {
            label: 'Help',
            submenu: [
                {
                    label: 'About',
                    click: () => {
                        dialog.showMessageBox(mainWindow, {
                            type: 'info',
                            title: 'About',
                            message: 'Electron + Vue3 + Symfony Desktop App',
                            detail: `Version: ${app.getVersion()}\nElectron: ${process.versions.electron}\nNode: ${process.versions.node}\nChrome: ${process.versions.chrome}`
                        })
                    }
                }
            ]
        }
    ]

    const menu = Menu.buildFromTemplate(template)
    Menu.setApplicationMenu(menu)
}

// App lifecycle
app.whenReady().then(() => {
    console.log('Electron app ready')
    
    // Create main window
    createWindow()
    createMenu()

    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0) {
            createWindow()
        }
    })
})

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit()
    }
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
        chromeVersion: process.versions.chrome,
        isDev: isDev
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

// File system operations
ipcMain.handle('read-file', async (event, filePath) => {
    try {
        const data = await fs.readFile(filePath, 'utf-8')
        return { success: true, data }
    } catch (error) {
        return { success: false, error: error.message }
    }
})

ipcMain.handle('write-file', async (event, filePath, content) => {
    try {
        await fs.writeFile(filePath, content, 'utf-8')
        return { success: true }
    } catch (error) {
        return { success: false, error: error.message }
    }
})

// Window management
ipcMain.handle('create-new-window', () => {
    const newWindow = createWindow()
    return newWindow ? true : false
})

// File system operations
ipcMain.handle('list-directory', async (event, dirPath) => {
    try {
        const items = await fs.readdir(dirPath, { withFileTypes: true })
        const result = items.map(item => ({
            name: item.name,
            isDirectory: item.isDirectory(),
            isFile: item.isFile()
        }))
        return { success: true, items: result }
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
        uptime: os.uptime(),
        loadavg: os.loadavg()
    }
})

// Dialog operations
ipcMain.handle('show-save-dialog', async (event, options) => {
    if (mainWindow) {
        const result = await dialog.showSaveDialog(mainWindow, options)
        return result
    }
    return { canceled: true }
})

ipcMain.handle('show-open-dialog', async (event, options) => {
    if (mainWindow) {
        const result = await dialog.showOpenDialog(mainWindow, options)
        return result
    }
    return { canceled: true }
})

// External operations
ipcMain.handle('open-external', async (event, url) => {
    try {
        await shell.openExternal(url)
        return { success: true }
    } catch (error) {
        return { success: false, error: error.message }
    }
})

// Error handling
process.on('uncaughtException', (error) => {
    console.error('Uncaught Exception:', error)
})

process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason)
})

console.log('Electron main process loaded')
