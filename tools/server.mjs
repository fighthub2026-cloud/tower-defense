import http from "node:http";
import { readFile, realpath, stat } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import path from "node:path";
import { spawn } from "node:child_process";
const root = path.resolve(fileURLToPath(new URL("../", import.meta.url)));
const mime = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".json": "application/json",
  ".png": "image/png",
};
export async function serve(req, res) {
  try {
    const pathname = decodeURIComponent(
      new URL(req.url, "http://localhost").pathname,
    );
    if (pathname === "/favicon.ico") {
      res.writeHead(204);
      res.end();
      return;
    }
    const candidate = path.resolve(
      root,
      "." + (pathname === "/" ? "/index.html" : pathname),
    );
    if (!candidate.startsWith(root + path.sep) && candidate !== root) {
      res.writeHead(403);
      res.end("Acesso negado");
      return;
    }
    const file = await realpath(candidate);
    if (!file.startsWith(root + path.sep) || !(await stat(file)).isFile()) {
      res.writeHead(403);
      res.end();
      return;
    }
    if (!["GET", "HEAD"].includes(req.method)) {
      res.writeHead(405);
      res.end();
      return;
    }
    const data = await readFile(file);
    res.writeHead(200, {
      "Content-Type": mime[path.extname(file)] || "application/octet-stream",
      "Cache-Control": "no-store",
      "X-Content-Type-Options": "nosniff",
    });
    res.end(req.method === "HEAD" ? undefined : data);
  } catch (e) {
    res.writeHead(e instanceof URIError ? 400 : 404);
    res.end("Arquivo não encontrado");
  }
}
export function openBrowser(url) {
  const command =
    process.platform === "win32"
      ? "cmd"
      : process.platform === "darwin"
        ? "open"
        : "xdg-open";
  const args = process.platform === "win32" ? ["/c", "start", "", url] : [url];
  const child = spawn(command, args, { stdio: "ignore", detached: true });
  child.on("error", () => console.log("Abra manualmente: " + url));
  child.unref();
}
if (
  process.argv[1] &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)
) {
  const server = http.createServer(serve);
  const port = Number(process.env.PORT || 3000);
  server.on("error", (e) => {
    console.error(
      e.code === "EADDRINUSE"
        ? `A porta ${port} está ocupada. Feche a outra instância ou defina PORT.`
        : e.message,
    );
    process.exitCode = 1;
  });
  server.listen(port, "127.0.0.1", () => {
    const url = `http://localhost:${server.address().port}`;
    console.log(
      `\nPinguins vs. Gosmas\n${url}\nMantenha esta janela aberta. Ctrl+C encerra o servidor.\n`,
    );
    if (process.argv.includes("--open")) openBrowser(url);
  });
  process.on("SIGINT", () => server.close(() => process.exit(0)));
}
