package types

// Context contains information and values relating to the function context
type Context struct {
	// MemoryLimitInMB is the execution limit that this function has, because of parallel execution of requests with a function
	// this limit is actually shared with the container
	MemoryLimitInMB int
	// CPULimitInMhz is the execution limit that this function has, because of parallel execution of requests with a function
	// this limit is actually shared with the container
	CPULimitInMhz int
	// FunctionName is the name of the function as invoked
	FunctionName string
	// FunctionVersion of the function, this is parsed from the container tag
	FunctionVersion
	// Headers is a dictionary of http headers sent with the request, this needs to cater for a function invocation
	// which may originate from an event
	Headers map[string]string
	// Env contains any environment variables set on function, this is parsed out from the global
	// env vars which are available to the process
	Env map[string]string
	// Secrets contains a dictionary of secrets available to the function
	Secrets map[string]string
	// Claims is reserved and will eventually contain a list of permissions that the function has
	Claims map[string]string

	// Logger implements a convenience methods for logging output from the function
	Log Logger
}

// Response allows output to be written by the function
type Response interface {
	// Write the response from the function, where possible the output should be streamed to the underlying language writer
	Write(data []byte, ctx Context)
	// Error writes an error to the function output
	Error(code int, message string)
}

// Logger defines convenience methods for writing arbitary log data
type Logger interface {
	// Info writes a simple message to std out
	Info(message string)
	// Infof writes a formatted message to std out
	Infof(format string, args interface{}...)
	// Error writes a simple messge to std err
	Error(message string)
	// Errorf writes a formatted message to std err
	Errorf(format string, args interface{}...)
}
