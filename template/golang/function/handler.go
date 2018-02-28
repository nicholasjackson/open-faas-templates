package function

import (
	"fmt"
)

// Handle a serverless request
func Handle(req []byte, ctx Context, resp Response) string {
	return fmt.Sprintf("Hello, Go. You said: %s", string(req))
}
