2701910150000085000018493817



markdownBarcode

<![CDATA[$!{markdownBarcode}]]>


#if("$!{holder.isCalculateWeight($record)}" == false))
 <text fill="#000000" stroke="#000" stroke-width="0" x="3" y="197.93772" id="svg_5" font-size="36" font-family="Gilroy-SemiBold" text-anchor="start" xml:space="preserve" font-weight="bold">$!{ware.extVO.specQty} $!{ware.extVO.specUnit}</text>
#end


#if($!{district.length()} > 9)


#else
                    	<li>$!{district}</li>
					#end
					



reflect.formatDate(printDate, 'dd/MM/yy')

<![CDATA[$!{reflect.formatDate($printDate, 'dd/MM/yy')}]]>

<![CDATA[$!{reflect.formatDate($printDate, 'dd/MM/yy')}]]>