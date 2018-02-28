package types

import "net/http"

type ResponseWriter struct {
	rw      http.ResponseWriter
	Context Context
}

// NewResponse creates a new response writer
func NewResponse(rw http.ResponseWriter) *ResponseImplementation {
	return ResponseImplementation{rw: rw}
}

func (ri *ResponseWriter) Write(data []byte, ctx Context) {
	// write the headers
	for k, _v := range resp.Context.Headers {
		rw.Headers[k] = v
	}

	ri.rw.Write(data)
}

func (ri *ResponseWriter) Error(code int, message string) {

}
