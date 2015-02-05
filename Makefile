all: example-en.html example-zh.html

example-en.html:
	pandoc example.md -t html -F ./trans.en -o $@

example-zh.html:
	pandoc example.md -t html -F ./trans.zh -o $@

clean:
	rm example-*.html
