<?php
// Minimal placeholder for API while Symfony is not fully installed
$uri = $_SERVER['REQUEST_URI'] ?? '/';
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

// Basic CORS handling for API requests so the frontend (Vite/Tauri) can call the backend
if (strpos($uri, '/api') === 0) {
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Accept');

    // Handle preflight CORS requests
    if ($method === 'OPTIONS') {
        http_response_code(204);
        exit;
    }

    header('Content-Type: application/json');
    echo json_encode(['status' => 'ok', 'message' => 'Backend placeholder API is running']);
    exit;
}

// Serve a simple HTML welcome page for other routes
?><!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Backend Placeholder</title>
    <style>body{font-family:Arial,Helvetica,sans-serif;background:#111;color:#eee;padding:2rem}</style>
  </head>
  <body>
    <h1>Backend Placeholder</h1>
    <p>This is a minimal placeholder for the Symfony backend. API endpoint <code>/api</code> returns a JSON status.</p>
  </body>
</html>
