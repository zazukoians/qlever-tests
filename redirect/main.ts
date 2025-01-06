const PUBLIC_MAPS_URL =
  Deno.env.get("PUBLIC_MAPS_URL") || "http://localhost:7004";
const PUBLIC_BACKEND_URL =
  Deno.env.get("PUBLIC_BACKEND_URL") || "http://localhost:7001";
const PRIVATE_BACKEND_URL =
  Deno.env.get("PRIVATE_BACKEND_URL") || "http://server-local:7001";

const handler = async (req: Request): Promise<Response> => {
  const url = new URL(req.url);

  // Construct the redirect URL to PUBLIC_MAPS_URL
  let targetUrl = new URL(PUBLIC_MAPS_URL);
  targetUrl.pathname = url.pathname;
  targetUrl.search = url.search;

  // Rewrite backend query parameter if it exists
  if (url.searchParams.has("backend")) {
    const backendUrl = url.searchParams.get("backend");
    console.log("backendUrl", backendUrl);
    if (backendUrl && backendUrl.includes(PUBLIC_BACKEND_URL)) {
      console.log("rewriting backend URL");
      const rewrittenUrl = backendUrl.replace(
        PUBLIC_BACKEND_URL,
        PRIVATE_BACKEND_URL
      );
      targetUrl.searchParams.set("backend", rewrittenUrl);
      console.log("rewritten backend URL", rewrittenUrl);
    }
  }

  // Redirect the client to the new URL
  return Response.redirect(targetUrl.toString(), 302);
};

Deno.serve({ hostname: "0.0.0.0", port: "7003" }, handler);
