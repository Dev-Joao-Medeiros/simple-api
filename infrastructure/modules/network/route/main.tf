locals {
  routes = jsondecode(var.routes_json)
}

resource "aws_route" "this" {
  for_each       = toset(var.route_keys)
  route_table_id = var.route_table_id

  # Destino (aceita 'destination_cidr_block' OU 'cidr_block' no JSON)
  destination_cidr_block = try(coalesce(
    lookup(local.routes[each.key], "destination_cidr_block", null),
    lookup(local.routes[each.key], "cidr_block", null)
  ), null)

  destination_ipv6_cidr_block = try(coalesce(
    lookup(local.routes[each.key], "destination_ipv6_cidr_block", null),
    lookup(local.routes[each.key], "ipv6_cidr_block", null)
  ), null)

  destination_prefix_list_id = try(local.routes[each.key].destination_prefix_list_id, null)

  # Alvo (use apenas 1 por rota)
  gateway_id                = try(local.routes[each.key].gateway_id, null) # IGW/VGW
  nat_gateway_id            = try(local.routes[each.key].nat_gateway_id, null)
  transit_gateway_id        = try(local.routes[each.key].transit_gateway_id, null)
  vpc_peering_connection_id = try(local.routes[each.key].vpc_peering_connection_id, null)
  vpc_endpoint_id           = try(local.routes[each.key].vpc_endpoint_id, null)
  egress_only_gateway_id    = try(local.routes[each.key].egress_only_gateway_id, null)
  network_interface_id      = try(local.routes[each.key].network_interface_id, null)
  core_network_arn          = try(local.routes[each.key].core_network_arn, null)
  local_gateway_id          = try(local.routes[each.key].local_gateway_id, null)
  carrier_gateway_id        = try(local.routes[each.key].carrier_gateway_id, null)
}
