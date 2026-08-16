jq_filter='select(
  (.objectRef.resource=="secrets") or
  (.objectRef.resource=="pods" and .verb=="create" and .stage=="RequestReceived" and .objectRef.name) or
  (.objectRef.subresource=="exec") or
  (.objectRef.resource=="rolebindings" and .verb=="create" and .stage=="RequestReceived")
)'

jq -s "map($jq_filter) | flatten" audit.log > audit-extract.json
