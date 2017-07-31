# basic checks
isFunction <- function(code)
  grepl("^[[:alnum:][:space:]_&:<>]*\\([[:alnum:][:space:]_&:<>,]*\\)[[:space:]]*\\{", code)

# pull the ampersand up to the type
sanitize_amp <- function(code) gsub("[[:space:]]+&([[:alnum:]_])", "& \\1", code)

# split into fdef, args, rest
tokenize_sig <- function(code)
  strsplit(code, "[[:space:]]*(\\(|\\)){1}[[:space:]]*")[[1]]

# get the arguments
.args <- function(code, split=FALSE) {
  args <- tokenize_sig(code)[[2]]
  if (split) args <- strsplit(args, "[[:space:]]*,[[:space:]]*")[[1]]
  args
}

# get the function name
.fname <- function(code) {
  tokens <- strsplit(tokenize_sig(code)[[1]], "[[:space:]]+")[[1]]
  tokens[[length(tokens)]]
}

# get the type (for a function or argument)
.type <- function(code) {
  tokens <- strsplit(tokenize_sig(code)[[1]], "[[:space:]]+")[[1]]
  tokens <- tokens[seq_len(length(tokens)-1)]
  paste(tokens[tokens != ""], collapse=" ")
}
