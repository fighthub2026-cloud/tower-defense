import test from "node:test";
import assert from "node:assert/strict";
import http from "node:http";
import { serve } from "../tools/server.mjs";
test("servidor entrega módulos e bloqueia acesso fora do projeto", async () => {
  const server = http.createServer(serve);
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  const base = `http://127.0.0.1:${server.address().port}`;
  try {
    const html = await fetch(base);
    assert.equal(html.status, 200);
    assert.match(await html.text(), /type="module"/);
    const js = await fetch(base + "/src/main.js");
    assert.equal(js.status, 200);
    assert.match(js.headers.get("content-type"), /javascript/);
    const missing = await fetch(base + "/nao-existe.js");
    assert.equal(missing.status, 404);
    const traversal = await fetch(base + "/%2e%2e%2fpackage.json");
    assert.equal(traversal.status, 403);
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
});
