import { test, expect } from "@playwright/test";

/**
 * Before running the tests, we need to start the local stack.
 * We can do this by running the following commands:
 *  docker compose --profile local up -d
 *
 * To stop the local stack, run the following command:
 *  docker compose --profile local down
 */

test.describe("Local stack", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("http://127.0.0.1:7002/default");
  });

  test("has index information", async ({ page }) => {
    await expect(page.locator("button#statsButton")).toHaveText(
      "Index Information"
    );
  });

  test("should be able to perform a query", async ({ page }) => {
    await page
      .getByRole("textbox")
      .fill("SELECT * WHERE { ?s ?p ?o } LIMIT 10");
    await page.getByRole("button", { name: /.*Execute/ }).click();
    await expect(
      page.locator("#answerBlock div").filter({ hasText: "Query results:" })
    ).toBeVisible();
    await expect(
      page.getByRole("button", { name: /.*10 lines found/ })
    ).toBeVisible();
  });
});
