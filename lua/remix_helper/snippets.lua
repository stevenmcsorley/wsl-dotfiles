-- ~/.config/nvim/lua/remix_helper/snippets.lua

local ls = require('luasnip')

-- Add your Remix snippets here
ls.add_snippets('typescriptreact', {
  ls.parser.parse_snippet('remixroute', [[
import { LoaderFunction } from "@remix-run/node";

export const loader: LoaderFunction = async ({ request }) => {
  // Your loader code
};

export default function Component() {
  return (
    <div>
      $0
    </div>
  );
}
  ]]),
})

ls.add_snippets('typescriptreact', {
  ls.parser.parse_snippet('remixroutefull', [[
import { LoaderFunction, ActionFunction, MetaFunction } from "@remix-run/node";
import { json, redirect } from "@remix-run/node";
import { useLoaderData } from "@remix-run/react";

export const loader: LoaderFunction = async ({ request }) => {
  // Fetch data or perform logic
  return json({ data: "your data" });
};

export const action: ActionFunction = async ({ request }) => {
  // Handle POST, PUT, DELETE
  return redirect('/');
};

export const meta: MetaFunction = () => {
  return {
    title: "Page Title",
    description: "Page description",
  };
};

export default function Component() {
  const data = useLoaderData();
  return (
    <div>
      <h1>Route Component</h1>
      <p>Data: {data}</p>
    </div>
  );
}
  ]]),
})

-- Add more snippets here...

-- Return the module
return {}
