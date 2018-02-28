package function

import (
	"github.com/nicholasjackson/github.com/nicholasjackson/open-faas-templates/golang/types"
)

// Handle a serverless request
func Handle(req []byte, ctx types.Context, resp types.Response) {
	resp.Write(req, ctx)
}
