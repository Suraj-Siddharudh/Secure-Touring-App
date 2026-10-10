# Secure-Touring-App

<p align="center">
</p>

The project is done using the concepts of Ruby on Rails. Started out as a Cource Requirement (forked from [click here](https://github.com/Suraj-Siddharudh/Tour-Management-System), significant changes were made to secure the appliaction.

The purpose of this project is to design a portal for booking tours. In the project, there are three access models: admin, agent and users. Users can create tours and edit their tours. Agents can edit the bookings of the users and the tours and user details. Admin has access to all the functionalities.
 

## Tech Stack

| Component | Version |
| --- | --- |
| Ruby | 4.0.7 (pinned in `.ruby-version`) |
| Rails | 8.1 |
| Database | SQLite 3 (development and test), PostgreSQL (production) |
| Authentication | Devise, with optional Google sign in (OmniAuth) |
| Image uploads | CarrierWave + MiniMagick (needs ImageMagick installed) |
| Assets | Sprockets, Dart Sass, Terser |

## Installation

You need four things on your machine: **Git**, **Ruby 4.0.7**, **ImageMagick** and, for
production only, **PostgreSQL**. SQLite and the PostgreSQL client library are bundled with
the `sqlite3` and `pg` gems on macOS and Linux, so you do not have to install them to run
the app locally.

Pick the section for your operating system. Each one installs Ruby through a version manager
(rbenv or mise), which reads `.ruby-version` and installs exactly 4.0.7 without touching the
system Ruby.

### macOS (Homebrew)

1. Install [Homebrew](https://brew.sh) if you do not have it.
2. Install the system packages:

   ```sh
   brew install git imagemagick libyaml
   ```

3. Install Ruby, using **one** of these version managers:

   **rbenv**

   ```sh
   brew install rbenv ruby-build
   rbenv init                       # follow the printed instructions, then open a new terminal
   cd Secure-Touring-App
   rbenv install                    # installs the version in .ruby-version
   ```

   **mise**

   ```sh
   brew install mise
   echo 'eval "$(mise activate zsh)"' >> ~/.zshrc   # use bash instead of zsh if that is your shell
   cd Secure-Touring-App
   mise use ruby@4.0.7
   ```

4. Optional, for running in production mode locally: `brew install postgresql@17` and
   `brew services start postgresql@17`.

### Ubuntu / Debian

1. Install the system packages (the build tools are needed to compile Ruby):

   ```sh
   sudo apt update
   sudo apt install -y git curl build-essential libssl-dev libyaml-dev zlib1g-dev \
     libffi-dev libreadline-dev imagemagick
   ```

2. Install rbenv and Ruby:

   ```sh
   curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
   echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >> ~/.bashrc
   exec "$SHELL"
   cd Secure-Touring-App
   rbenv install                    # installs the version in .ruby-version
   ```

   The distribution's own `ruby` and `rbenv` packages are too old for Ruby 4.0, so use the
   installer above (or mise: `curl https://mise.run | sh`, then `mise use ruby@4.0.7`).

3. Optional, for production mode: `sudo apt install -y postgresql`.

### Fedora / RHEL

```sh
sudo dnf install -y git gcc make openssl-devel libyaml-devel zlib-devel libffi-devel \
  readline-devel ImageMagick
```

Then install rbenv and Ruby exactly as in the Ubuntu step 2.

### Windows

Native Windows is not supported by the locked gem set. Use **WSL2**:

1. In an administrator PowerShell, run `wsl --install -d Ubuntu` and restart.
2. Open the Ubuntu terminal and follow the **Ubuntu / Debian** steps above.
3. Clone the project inside the Linux file system (for example `~/code`), not under `/mnt/c`,
   or file watching and installs will be very slow.

### Check your setup

```sh
ruby -v          # ruby 4.0.7 ...
magick -version  # or `convert -version` on older ImageMagick; either is fine
```

## Getting Started

```sh
git clone https://github.com/Suraj-Siddharudh/Secure-Touring-App.git
cd Secure-Touring-App
bin/setup
```

`bin/setup` installs the gems, creates the SQLite database in `storage/`, runs the migrations,
seeds sample data and starts the server on http://localhost:3000. Use `bin/setup --skip-server`
to only prepare, and `bin/rails server` (or `bin/dev`) to start the server later.

If you prefer to run the steps yourself:

```sh
bundle install
bin/rails db:prepare   # create, migrate and seed
bin/rails server
```

### Seeded accounts

Seeding creates 15 agents, 10 customers, 15 tours and these three fixed accounts:

| Role | Email | Password variable |
| --- | --- | --- |
| Admin | `admin@touringapp.com` | `ADMIN_PASSWORD` |
| Agent | `agent@touringapp.com` | `AGENT_PASSWORD` |
| Customer | `customer@touringapp.com` | `CUSTOMER_PASSWORD` |

If a password variable is not set, a random password is generated and printed **once** in the
terminal during seeding. To choose your own, set the variables before seeding:

```sh
ADMIN_PASSWORD=choose-one AGENT_PASSWORD=choose-two CUSTOMER_PASSWORD=choose-three bin/rails db:seed
```

To start over with a fresh database: `bin/rails db:reset`. The admin account cannot be deleted
from the app. Accounts lock for one minute after 5 wrong passwords.

## Environment Variables

**No secrets are stored in this repository.** Every credential is read from an environment
variable at runtime. The app does not load `.env` files on its own, so set the variables in
your shell, your shell profile, a tool such as [direnv](https://direnv.net), or your hosting
provider's settings. `.env` is already in `.gitignore` if you keep one for your own use.

### What you need for each environment

| Environment | Required | Optional |
| --- | --- | --- |
| Development (`bin/rails server`) | Nothing | Google sign in, SMTP, seed passwords |
| Test (`bin/rails test`) | Nothing | None (tests never use real credentials) |
| Production | `SECRET_KEY_BASE`, `DATABASE_URL` | Google sign in, SMTP, `APP_HOST`, tuning |

### Full reference

| Variable | Purpose | When needed | Default |
| --- | --- | --- | --- |
| `SECRET_KEY_BASE` | Signs and encrypts sessions and cookies. Generate one with `bin/rails secret`. | Production | None. Development and test generate their own. |
| `DATABASE_URL` | PostgreSQL connection string, e.g. `postgres://user:password@db.example.com:5432/touring_app_production` | Production | None |
| `GOOGLE_CLIENT_ID` | OAuth client ID for "Sign in with Google" | Only for Google sign in | Not set (Google sign in fails, email sign in still works) |
| `GOOGLE_CLIENT_SECRET` | OAuth client secret for "Sign in with Google" | Only for Google sign in | Not set |
| `SMTP_USERNAME` | SMTP login, e.g. the Gmail address that sends mail | Only for sending email | Not set |
| `SMTP_PASSWORD` | SMTP password. For Gmail this must be an app password. | Only for sending email | Not set |
| `SMTP_ADDRESS` | SMTP server host | No | `smtp.gmail.com` |
| `SMTP_PORT` | SMTP server port (STARTTLS) | No | `587` |
| `SMTP_DOMAIN` | HELO domain sent to the SMTP server | No | `gmail.com` |
| `MAILER_FROM` | "From" address on all outgoing email | No | `no-reply@touringapp.com` |
| `APP_HOST` | Public host name used in links inside emails, e.g. `tours.example.com` | Production, if emails contain links | `example.com` |
| `ADMIN_PASSWORD` | Password for the seeded admin account | No | Random, printed during seeding |
| `AGENT_PASSWORD` | Password for the seeded agent account | No | Random, printed during seeding |
| `CUSTOMER_PASSWORD` | Password for the seeded customer account | No | Random, printed during seeding |
| `PORT` | Port the web server listens on | No | `3000` |
| `RAILS_MAX_THREADS` | Puma threads per process, also the database pool size | No | `3` (pool `5`) |
| `WEB_CONCURRENCY` | Number of Puma worker processes | No | Single process |
| `RAILS_LOG_LEVEL` | Production log level (`debug`, `info`, `warn`, `error`) | No | `info` |

`RAILS_MASTER_KEY` and `config/master.key` are **not** used. The encrypted credentials file
was removed, so there is nothing to decrypt.

### Getting the values

**`SECRET_KEY_BASE`**: run `bin/rails secret` and use the output. Keep it stable: changing it
signs every user out.

**Google sign in** (`GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`):

1. Open [Google Cloud Console](https://console.cloud.google.com/apis/credentials) and create
   an **OAuth client ID** of type **Web application**.
2. Under **Authorized redirect URIs** add the callback for each place the app runs:
   - `http://localhost:3000/users/auth/google/callback` for development
   - `https://<your-domain>/users/auth/google/callback` for production
3. Copy the client ID and client secret into the two variables.

**Gmail SMTP** (`SMTP_USERNAME`, `SMTP_PASSWORD`): turn on 2-Step Verification for the Google
account, then create an [app password](https://myaccount.google.com/apppasswords) and use it
as `SMTP_PASSWORD`. Your normal Gmail password will not work. For any other provider, also
set `SMTP_ADDRESS`, `SMTP_PORT` and `SMTP_DOMAIN`.

### Example: development with optional features

```sh
# ~/.zshrc, ~/.bashrc, or an .envrc file if you use direnv
export GOOGLE_CLIENT_ID="1234567890-abc.apps.googleusercontent.com"
export GOOGLE_CLIENT_SECRET="your-client-secret"
export SMTP_USERNAME="you@gmail.com"
export SMTP_PASSWORD="your-16-character-app-password"
```

Nothing else is needed for development; leave these out if you do not use Google sign in or
email.

### Example: production

```sh
export RAILS_ENV=production
export SECRET_KEY_BASE="output of bin/rails secret"
export DATABASE_URL="postgres://touring:strong-password@localhost:5432/touring_app_production"
export APP_HOST="tours.example.com"
export MAILER_FROM="no-reply@tours.example.com"
# plus GOOGLE_* and SMTP_* if you use those features
```

## Running the Tests

```sh
bin/rails test   # the full suite, uses its own SQLite database
bin/ci           # setup, tests and a seed check, as a CI server would run them
```

## Production

1. Create a PostgreSQL database and user, then set the production variables shown above.
2. Install gems without the development and test groups:

   ```sh
   bundle config set --local without "development test"
   bundle install
   ```

3. Build the assets and prepare the database:

   ```sh
   bin/rails assets:precompile
   bin/rails db:prepare   # creates the schema, and seeds only on the first run
   ```

4. Start the server: `bin/rails server`. Put it behind a reverse proxy that terminates HTTPS
   (nginx, Caddy, or your platform's load balancer). Uploaded tour images are stored in
   `public/uploads`, so keep that directory on persistent storage.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `rbenv install` says 4.0.7 is unknown | Update ruby-build: `brew upgrade ruby-build`, or `git -C ~/.rbenv/plugins/ruby-build pull` on Linux |
| Image upload fails with a MiniMagick error | ImageMagick is missing. Install it as shown above, then restart the server. |
| "Sign in with Google" shows a Google error page | `GOOGLE_CLIENT_ID`/`GOOGLE_CLIENT_SECRET` are not set, or the redirect URI in Google Cloud Console does not match exactly |
| Booking confirmation emails are not sent | Check `SMTP_USERNAME` and `SMTP_PASSWORD`. Gmail requires an app password. |
| Production fails with ``Missing `secret_key_base` `` | Set `SECRET_KEY_BASE`. Ignore the suggestion in the error to run `credentials:edit`; this project does not use encrypted credentials. |
| Production cannot connect to the database | Check `DATABASE_URL` and that PostgreSQL is running and reachable |
| An account is locked | Wait one minute. Resetting the password from the sign in page also works if email is configured. |

## Features created
### Admin
   - Log in with an email and password.
   - Edit profile 
   - Create agent and customer accounts (users).
   - View the list of all users and their profile details (except password).
   - Edit or delete users (agents or customers)/Tours/reviews from the system
   - View the list of all tours, along with detailed information.
   - View all fields of reviews (defined below) from customers.

### Agent
  - Login with email and password.
  - List a tour.  
  - Edit/update/delete/cancel tours that they have posted. (Cannot edit tours posted by other agents.)
  - View all tours (including those listed by others).
  - Upload and delete pictures of tours that they themselves have listed (Deleting can be done only by going to Edit Option). 
  - View list of all customers who have bookmarked a tour (created by them).
  - Agent should be able to delete his own account.
  - View reviews of a tour.
  - View list of all customers who have booked a tour.

### Customer
  - Log in with email and password.
  - Search available tours using filters, such as start date range, price range, tour name and locations visited during the tour (Itinerary)
  - Bookmark tours they are interested in.
  - Book n seats on a tour for "Active" Tours.
  - View information about tours
  - Customer is able to delete his own account.
  - Search available tours using filters, such as start date range, price range, tour name, slot availability and locations     visited during the tour (Itinerary)
  - Book n seats on a tour.
  - Cancel a booking completely or cancel a few seats from a booking done previously.
  - Submit a review for a tour that that customer has already taken.
  - Edit or delete a review they previously submitted.

### Miscellaneous
   - Testing is thoroughly done for the user model and user controller.
   - All users can use their **Google account** with NCSU email id to log into the system
   - An email is sent when the status of the customer moves from waitlist to booked.

### Note
   - For partial cancellation of booking, please use update functionality from "My Bookings"
   - Customer can add review only after booking a tour and status is "Completed".
   - Tours cannot be booked if status is "Completed".
   - Tours with "Active" status corresponds to both ongoing tours and upcoming tours.

Please create a pull request if you want to contribute to the development of this project
