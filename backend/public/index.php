<?php
// Minimal placeholder for API while Symfony is not fully installed
$uri = $_SERVER['REQUEST_URI'] ?? '/';

if (strpos($uri, '/api') === 0) {
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
