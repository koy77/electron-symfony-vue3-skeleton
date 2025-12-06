const { contextBridge, ipcRenderer } = require('electron')

// Expose protected methods that allow the renderer process to use
// the ipcRenderer without exposing the entire object
contextBridge.exposeInMainWorld('electronAPI', {
    // App info
    getAppVersion: () => ipcRenderer.invoke('get-app-version'),
    getPlatform: () => ipcRenderer.invoke('get-platform'),

    // File system (example)
    readFile: (filePath) => ipcRenderer.invoke('read-file', filePath),

    // You can add more IPC methods here as needed
})

// Expose a flag to detect if running in Electron
contextBridge.exposeInMainWorld('isElectron', true)
