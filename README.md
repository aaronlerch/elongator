# UniformResourceLocatorElongator.com
If URL shorteners go for the shortest name possible, then shouldn't an
"elongator" use the longest name it can? Certainly seems so.

## Features
Uniformresourcelocatorelongator offers a simple json API to query
multiple URLs, returning a hash of original URL => resolved URL.

The elongator uses Redis as a data store to avoid looking up a URL more
than once. For new URLs, the elongator issues a HEAD request and looks
for a 301 redirect. This is currently a naive implementation in that it
does not pay attention to caching rules, it simply permanently stores
the redirected URL.

## Random Notes

Color scheme: http://colorschemedesigner.com/#4461zJLbv.q6s
