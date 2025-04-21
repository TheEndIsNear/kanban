module "swarm" {
  source = "../../modules/cloud/aws/compute/swarm"
}

import {
  to = module.swarm.aws_security_group.swarm_sg
  id = "sg-0e58912ab10413cf4"
}
