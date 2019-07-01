# Installation Manual

This file contains information on how to deploy this web app.

## Requirements

- nodejs (11.10.0) ([nodejs.org](https://nodejs.org/en/))
- yarn ([yarnpkg.com](https://yarnpkg.com/en/docs/install))
- serve (`yarn global add serve`) (or other static server of your choice)

## How to deploy

### `yarn install`

Installs all project dependencies.

### `cp .env.sample .env`
### `source .env`

Edit `.env` file and put the API url.

### `yarn build`

Builds the app for production to the `build` folder.<br>
It correctly bundles React in production mode and optimizes the build for the best performance.

The build is minified and the filenames include the hashes.<br>
Your app is ready to be deployed!

See the section about [deployment](https://facebook.github.io/create-react-app/docs/deployment) for more information.

### `serve -s build -l PORT`

Start a static server in the build directory in a PORT of your choice.

## Advanced Information
#### Advanced Configuration

This section has moved [here](https://facebook.github.io/create-react-app/docs/advanced-configuration).

#### Deployment

This section has moved [here](https://facebook.github.io/create-react-app/docs/deployment).
