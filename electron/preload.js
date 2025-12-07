const { contextBridge, ipcRenderer } = require('electron')

// Expose protected methods that allow the renderer process to use
// the ipcRenderer without exposing the entire object
contextBridge.exposeInMainWorld('electronAPI', {
    // App info
    getAppVersion: () => ipcRenderer.invoke('get-app-version'),
    getPlatform: () => ipcRenderer.invoke('get-platform'),
    getAppInfo: () => ipcRenderer.invoke('get-app-info'),

    // Window management
    minimizeWindow: () => ipcRenderer.invoke('minimize-window'),
    maximizeWindow: () => ipcRenderer.invoke('maximize-window'),
    closeWindow: () => ipcRenderer.invoke('close-window'),

    // File system
    readFile: (filePath) => ipcRenderer.invoke('read-file', filePath),
    writeFile: (filePath, content) => ipcRenderer.invoke('write-file', filePath, content),

    // System information
    getSystemInfo: () => ipcRenderer.invoke('get-system-info'),

    // Events
    onWindowEvent: (callback) => {
        ipcRenderer.on('window-event', (event, data) => callback(data))
    },
    removeAllListeners: (channel) => {
        ipcRenderer.removeAllListeners(channel)
    }
})

// Expose a flag to detect if running in Electron
contextBridge.exposeInMainWorld('isElectron', true)

// Log that preload script has loaded
console.log('Electron preload script loaded successfully')
