# hubot-vividcortex

Vividcortex integration for Hubot

## Installation

Add **hubot-vividcortex** to your `package.json` file:

```
npm install hubot-vividcortex --save
```
Add **hubot-vividcortex** to your `external-scripts.json`:

```json
["hubot-vividcortex"]
```

## Sample Commands

```
user1>> vc top-queries last hour
hubot>> [A wild image of the top queries for the last hour appears]
```

```
user1>> vc top-processes last 5 minutes
hubot>> [A wild image of the top processes for the last 5 minutes appears]
```

See [`src/vividcortex.coffee`](src/vividcortex.coffee) for more commands.
