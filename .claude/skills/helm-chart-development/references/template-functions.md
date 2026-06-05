# Helm Template Functions Reference

## String Functions

```yaml
# Trim whitespace
{{ trim "  hello  " }}  # "hello"

# Trim prefix/suffix
{{ trimPrefix "-" "-hello" }}  # "hello"
{{ trimSuffix "-" "hello-" }}  # "hello"

# Upper/lower case
{{ upper "hello" }}  # "HELLO"
{{ lower "HELLO" }}  # "hello"

# Title case
{{ title "hello world" }}  # "Hello World"

# Quote
{{ quote "hello" }}  # "\"hello\""
{{ squote "hello" }}  # "'hello'"

# Replace
{{ replace " " "-" "hello world" }}  # "hello-world"

# Contains/HasPrefix/HasSuffix
{{ contains "lo" "hello" }}  # true
{{ hasPrefix "he" "hello" }}  # true
{{ hasSuffix "lo" "hello" }}  # true

# Truncate
{{ trunc 5 "hello world" }}  # "hello"
{{ trunc -5 "hello world" }}  # "world"

# Abbreviate (truncate with ellipsis)
{{ abbrev 8 "hello world" }}  # "hello..."

# Substring
{{ substr 0 5 "hello world" }}  # "hello"

# Split/Join
{{ split "-" "a-b-c" }}  # {_0: a, _1: b, _2: c}
{{ join "-" (list "a" "b" "c") }}  # "a-b-c"

# Regex
{{ regexMatch "^[a-z]+$" "hello" }}  # true
{{ regexReplaceAll "[0-9]" "a1b2c3" "X" }}  # "aXbXcX"

# Indent/nindent
{{ indent 4 "hello" }}   # "    hello"
{{ nindent 4 "hello" }}  # "\n    hello"
```

## Type Conversion

```yaml
# To string
{{ toString 123 }}  # "123"

# To integer
{{ int "123" }}  # 123
{{ int64 "123" }}  # 123

# To float
{{ float64 "1.23" }}  # 1.23

# To boolean
{{ toJson true }}  # true

# Type checking
{{ kindOf "hello" }}  # "string"
{{ typeOf "hello" }}  # "string"
{{ kindIs "string" "hello" }}  # true
```

## Math Functions

```yaml
# Basic math
{{ add 1 2 }}  # 3
{{ sub 5 2 }}  # 3
{{ mul 2 3 }}  # 6
{{ div 6 2 }}  # 3
{{ mod 5 2 }}  # 1

# Min/Max
{{ min 1 2 3 }}  # 1
{{ max 1 2 3 }}  # 3

# Floor/Ceil/Round
{{ floor 1.9 }}  # 1
{{ ceil 1.1 }}  # 2
{{ round 1.5 }}  # 2
```

## List Functions

```yaml
# Create list
{{ list "a" "b" "c" }}

# First/Last/Rest/Initial
{{ first (list "a" "b" "c") }}  # "a"
{{ last (list "a" "b" "c") }}  # "c"
{{ rest (list "a" "b" "c") }}  # ["b", "c"]
{{ initial (list "a" "b" "c") }}  # ["a", "b"]

# Append/Prepend
{{ append (list "a" "b") "c" }}  # ["a", "b", "c"]
{{ prepend (list "b" "c") "a" }}  # ["a", "b", "c"]

# Concat
{{ concat (list "a") (list "b") }}  # ["a", "b"]

# Reverse
{{ reverse (list "a" "b" "c") }}  # ["c", "b", "a"]

# Uniq
{{ uniq (list "a" "a" "b") }}  # ["a", "b"]

# Without
{{ without (list "a" "b" "c") "b" }}  # ["a", "c"]

# Has
{{ has "a" (list "a" "b") }}  # true

# Compact (remove empty)
{{ compact (list "a" "" "b") }}  # ["a", "b"]

# Slice
{{ slice (list "a" "b" "c" "d") 1 3 }}  # ["b", "c"]

# Length
{{ len (list "a" "b" "c") }}  # 3
```

## Dictionary Functions

```yaml
# Create dict
{{ dict "key1" "value1" "key2" "value2" }}

# Get value
{{ get (dict "key" "value") "key" }}  # "value"

# Set value
{{ set $myDict "newKey" "newValue" }}

# Unset
{{ unset $myDict "key" }}

# Has key
{{ hasKey (dict "key" "value") "key" }}  # true

# Keys/Values
{{ keys (dict "a" 1 "b" 2) }}  # ["a", "b"]
{{ values (dict "a" 1 "b" 2) }}  # [1, 2]

# Merge (rightmost wins)
{{ merge (dict "a" 1) (dict "b" 2) }}  # {"a": 1, "b": 2}

# Deep copy
{{ deepCopy $myDict }}

# Pick/Omit
{{ pick (dict "a" 1 "b" 2 "c" 3) "a" "c" }}  # {"a": 1, "c": 3}
{{ omit (dict "a" 1 "b" 2 "c" 3) "b" }}  # {"a": 1, "c": 3}
```

## Flow Control

```yaml
# If/Else
{{- if .Values.enabled }}
enabled: true
{{- else }}
enabled: false
{{- end }}

# With (change scope)
{{- with .Values.config }}
key: {{ .key }}
{{- end }}

# Range (iterate)
{{- range .Values.items }}
- {{ . }}
{{- end }}

# Range with index
{{- range $index, $item := .Values.items }}
- {{ $index }}: {{ $item }}
{{- end }}

# Range over dict
{{- range $key, $value := .Values.env }}
- name: {{ $key }}
  value: {{ $value }}
{{- end }}

# Default value
{{ .Values.name | default "myapp" }}

# Coalesce (first non-empty)
{{ coalesce .Values.name .Values.nameOverride "default" }}

# Ternary
{{ ternary "yes" "no" .Values.enabled }}

# Empty check
{{- if empty .Values.name }}
name not set
{{- end }}

# Required (fail if empty)
{{ required "name is required" .Values.name }}

# Fail
{{- if .Values.deprecated }}
{{- fail "deprecated option used" }}
{{- end }}
```

## Encoding Functions

```yaml
# Base64
{{ b64enc "hello" }}  # "aGVsbG8="
{{ b64dec "aGVsbG8=" }}  # "hello"

# JSON
{{ toJson .Values.config }}
{{ fromJson "{\"key\": \"value\"}" }}

# YAML
{{ toYaml .Values.config }}
{{ fromYaml "key: value" }}

# SHA256
{{ sha256sum "hello" }}

# UUID
{{ uuidv4 }}
```

## Date Functions

```yaml
# Current time
{{ now }}
{{ now | date "2006-01-02" }}

# Format
{{ now | date "2006-01-02T15:04:05Z07:00" }}

# Add duration
{{ now | dateModify "+1h" }}
{{ now | dateModify "-24h" }}

# Unix timestamp
{{ now | unixEpoch }}
```

## File Functions

```yaml
# Include file
{{ .Files.Get "config.yaml" }}

# Glob files
{{- range $path, $content := .Files.Glob "configs/*" }}
{{ $path }}: |
{{ $content | indent 2 }}
{{- end }}

# As config/secret
{{ .Files.Get "config.yaml" | b64enc }}
```

## Lookup Function

```yaml
# Get existing resource
{{- $secret := lookup "v1" "Secret" .Release.Namespace "my-secret" }}
{{- if $secret }}
password: {{ $secret.data.password }}
{{- end }}
```
