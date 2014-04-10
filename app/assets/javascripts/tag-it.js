(function($) {

	$.fn.tagit = function(options) {
                var el = this;
                create_preview()
                function split( val ) {
			return val.split(/[\s]+/);
		}
		function extractLast( term ) {
			return split( term ).pop();
		}

                this.bind("keyup",function( event ) {
                    create_preview()
                })
                .bind("keydown",function( event ) {
                    if ( event.keyCode === $.ui.keyCode.TAB && $( this ).data( "autocomplete" ).menu.active ) {
                            event.preventDefault();
                    }
                    if(event.keyCode === $.ui.keyCode.ENTER){
                            return false;
                    }

                    if(event.keyCode === $.ui.keyCode.COMMA || event.keyCode === $.ui.keyCode.SPACE ){
                        this.value = this.value.toLowerCase()
                        var terms = split(this.value)
                        terms.pop();
                        terms.push( extractLast( this.value ) );
//                        terms.push( "" ); // dodaje niepotrzebna spacje
                        terms = findDuplicates(terms)
                        this.value = terms.join( " " );
                    }
                })
		.autocomplete({
                        source: function( request, response ) {
                            $.getJSON( options.sourceTags, {
                                    term: extractLast( request.term )
                            }, response );
 
                        },
                        focus: function() {
                            return false;
                        },
                        search: function() {
                            var term = extractLast( this.value );
                            if ( term.length < 2 ) {
                                    return false;
                            }
			},
			select: function( event, ui ) {
                            this.value = this.value.toLowerCase()
                            var terms = split( this.value);
                            terms.pop();
                            terms.push( ui.item.value );
                            terms.push( "" );
                            terms = findDuplicates(terms)
                            this.value = terms.join( " " );
                            el.val(this.value) // replace with autocomplete
                            create_preview()
                            return false;
                        }
		});
                function findDuplicates(arr) {
                   var i,
                      len=arr.length,
                      out=[],
                      obj={};

                  for (i=0;i<len;i++) {
                    obj[arr[i]]=0;
                  }
                  for (i in obj) {
                    out.push(i);
                  }
                  return out;

                }
                function showSpecialTag(name){
                    current_tag = "spc_" + name.replace(/[^A-Za-z]+/, '')
                    if(jQuery.inArray(current_tag, options.specialTags) >= 0){
                        return current_tag
                    }
                    return ''
                }

                function create_preview(){
                    html = '<div class="tags">'
                    jQuery.each(split(el.val()),function(i,v){
                        if(v != ""){
                            v = v.replace(/[^a-z0-9ąćęóźżłńś-]+/gi,"")
                            html += '<div class="tag '+showSpecialTag(v)+'">'
                            html += '<a href="' + options.linkTags + '/' + v + '">' + v + '</a>'
                            html += '</div> '
                        }
                    });
                    html += "</div>"
                    $("#tags_preview").html(html)
                }
	};

})(jQuery);
