const { app, BrowserWindow, ipcMain } = require('electron')
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
        width: 1200,
        height: 800,
        webPreferences: {
            preload: path.join(__dirname, 'preload.js'),
            nodeIntegration: false,
            contextIsolation: true,
        },
        icon: path.join(__dirname, 'assets/icon.png'),
    })

    // Load the frontend
    mainWindow.loadURL(FRONTEND_URL)

    // Open DevTools in development mode
    if (isDev) {
        mainWindow.webContents.openDevTools()
    }

    mainWindow.on('closed', function () {
        mainWindow = null
    })
}

// App lifecycle
app.whenReady().then(() => {
    createWindow()

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

// Example: File system access
ipcMain.handle('read-file', async (event, filePath) => {
    const fs = require('fs').promises
    try {
        const data = await fs.readFile(filePath, 'utf-8')
        return { success: true, data }
    } catch (error) {
        return { success: false, error: error.message }
    }
})
