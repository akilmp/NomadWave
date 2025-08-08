import * as pulumi from "@pulumi/pulumi";
import * as command from "@pulumi/command";

const config = new pulumi.Config();
const nodes = config.requireObject<string[]>("nodes");
const username = config.require("username");
const privateKey = config.requireSecret("privateKey");
const consulServer = config.require("consulServer");
const nomadServer = config.require("nomadServer");

nodes.forEach((host, idx) => {
  const connection = {
    host,
    user: username,
    privateKey: privateKey,
  };

  new command.remote.Command(`setup-${idx}`, {
    connection,
    create: `set -e
if ! command -v nomad >/dev/null; then
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  sudo apt-add-repository "deb [arch=arm64] https://apt.releases.hashicorp.com \$(lsb_release -cs) main"
  sudo apt-get update
  sudo apt-get install -y nomad consul
fi
sudo systemctl enable nomad consul
sudo systemctl start nomad consul
consul join ${consulServer} || true
nomad server join ${nomadServer} || true
`,
  });
});
