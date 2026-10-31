# How Many of You? Setup guide

This puts the game on its own website so anyone can play from a link, with no account. It takes about 15 minutes, all free, and you do it once.

You'll use three free services:

- **Supabase** stores the games and the leaderboard.
- **GitHub** holds the website files.
- **Vercel** puts the website online and gives you the link.

## What's in this folder

| File | What it is |
|---|---|
| `index.html` | The game itself |
| `config.js` | Where you paste your two Supabase values (step 1) |
| `supabase-setup.sql` | Creates the database tables (step 1) |
| `api/play.js` | Makes each game's link preview say "How many Davids?" |
| `vercel.json`, `package.json` | Settings for Vercel. Don't change these. |
| `og.png`, `icon.png` | Link preview image and home-screen icon |

---

## Step 1: Set up the database (Supabase, about 5 minutes)

1. Go to **supabase.com**, click **Start your project**, and sign up.
2. Click **New project**.
   - Name: `how-many-of-you`
   - Database password: click **Generate a password** and save it somewhere. You won't need it for the game.
   - Region: pick the one closest to you, e.g. *East US*.
   - Click **Create new project** and wait about 2 minutes while it starts.
3. In the left sidebar, open **SQL Editor** and click **New query**.
4. Open `supabase-setup.sql` in Notepad, copy everything, paste it into the editor, and click **Run**. You should see *"Success. No rows returned."*
5. Open **Project Settings** (the gear icon) and go to the **API Keys** page. On older projects it's just called **API**. Copy two things:
   - **Project URL**, which looks like `https://abcdefgh.supabase.co`. It's on the **Data API** page (or the same **API** page).
   - **Publishable key**, which starts with `sb_publishable_`. On older projects, use the key labelled **anon public** instead.
   - ⚠️ Never use the **secret** or **service_role** key.
6. Open `config.js` in Notepad, replace the two placeholder values with yours, and save:

```js
window.HMOY_CONFIG = {
  supabaseUrl: "https://abcdefgh.supabase.co",
  supabaseKey: "sb_publishable_xxxxxxxxxxxx"
};
```

You can safely put both values on a public website. The database only lets visitors read games, create games and add guesses. Nobody can edit or delete anything, and the database works out the scores itself, so nobody can post a fake one.

## Step 2: Upload the files (GitHub, about 5 minutes)

1. Go to **github.com** and sign up.
2. Click the **+** at the top right, then **New repository**.
   - Name: `how-many-of-you`
   - Private or Public both work.
   - Click **Create repository**.
3. On the next page, click the **uploading an existing file** link.
4. Open the unzipped `how-many-of-you` folder on your computer. Select **everything inside it**, including the `api` folder, and drag it onto the GitHub page. Drag the contents, not the folder itself.
5. Check that `api/play.js` appears in the list, then click **Commit changes**.

## Step 3: Put it online (Vercel, about 3 minutes)

1. Go to **vercel.com**, click **Sign Up**, choose **Hobby** (free), and **Continue with GitHub**.
2. Click **Add New…**, then **Project**, and click **Import** next to `how-many-of-you`. If it isn't listed, click **Configure GitHub App** and allow access to the repository.
3. Leave **Framework Preset** as **Other** and click **Deploy**.
4. After about 30 seconds you'll get a link like `https://how-many-of-you.vercel.app`. That's your game.

To change the web address, go to the project's **Settings**, then **Domains**, and edit the `.vercel.app` name.

## Try it

1. Open your link on your iPhone, type a name, pick a place for each round, and tap **Create game link**.
2. Tap **Share…** to send it by iMessage, WhatsApp and so on, or tap **Copy**.
3. Game links look like `…vercel.app/how-many-davids-gk2m9xqab`, and the preview reads **"How many Davids?"**
4. Tip: in Safari, tap **Share**, then **Add to Home Screen**, to make it look like an app.

## Making changes later

Edit a file on GitHub: open it, click the pencil icon, and commit. Vercel republishes automatically within a minute.

- **Add a name:** in `index.html`, find `const NAMES=[` and add an entry like `["Anders",9000,170000]`. The format is name, then the number of people with that name in the US, then the number worldwide.
- **Add a place:** find `const PLACES=[` and add an entry like `["Lyon",520000,"w","France"]`. The letter after the population is the type of place: `c` = US city (followed by the state, e.g. `"CA"`), `s` = US state, `n` = country, `w` = city outside the US (followed by its country).

## If something goes wrong

| What you see | What to do |
|---|---|
| "This site isn't connected to its database yet" | `config.js` still has the placeholder values, or the edited file wasn't uploaded to GitHub. |
| "Couldn't save the game" | Check that the SQL in step 1.4 ran successfully and that you used the publishable/anon key. |
| Friends see a Vercel login page | In the Vercel project, go to **Settings** → **Deployment Protection** and turn off **Vercel Authentication**. |
| The game stopped working after a quiet week | Free Supabase projects pause after about 7 days with no activity. Open your Supabase dashboard and click **Restore project**. |
| The link preview still shows the old title | iMessage remembers previews. Create a new game and send its link. |
