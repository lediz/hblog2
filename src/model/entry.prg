//----------------------------------------------------------------------------//

CLASS EntryModel 

	DATA cAlias
	DATA nRegGrande init 10000000

	METHOD New()             		CONSTRUCTOR
	
	METHOD search( cSearch )
	METHOD Rows( nId, nRows )
	METHOD GetId( nId )
	
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New() CLASS EntryModel

	
	USE ( AppPathData() + 'entry.dbf' ) SHARED NEW VIA 'DBFCDX'
	SET INDEX TO 'entry.cdx'
	
	::cAlias := Alias()		

RETU SELF

METHOD search( cSearch ) CLASS EntryModel

	LOCAL hData 	:= {=>}
	LOCAL hRows 	:= {}
	LOCAL nCount 	:= 0
	LOCAL nRecno
   
	cSearch = lower( alltrim( cSearch ) )

	select ( ::cAlias )
	( ::cAlias )->( dbgotop() )
	locate for ( hb_WildMatch( "*"+cSearch+ "*", lower( ( ::cAlias )->titulo ) )  .or. ;
	             hb_WildMatch( "*"+cSearch+ "*", lower( ( ::cAlias )->texto  ) ) ) ;
			     .and. !( ::cAlias )->( eof() ) 

	while ( ::cAlias )->( found() )

		nRecno := (::cAlias)->( Recno() )
		Aadd( hRows, { '_recno'	=> nRecno,;
						'id' 		=> (::cAlias)->id,;
						'fecha'		=> (::cAlias)->fecha,;
						'titulo'	=> (::cAlias)->titulo,;
						'texto' 	=> (::cAlias)->texto ;
					})						
	
		nCount++						
		select ( ::cAlias )
		continue
	end		

	hData[ 'recno' ] := nRecno
	hData[ 'rows'  ] := hRows

RETU hData


METHOD Rows( nId, nRows ) CLASS EntryModel

	LOCAL hData 	:= {=>}
	LOCAL hRows 	:= {}
	LOCAL nCount 	:= 0
	LOCAL nRecno

	DEFAULT nId 		 TO 0
	DEFAULT nRows		 TO 5
	
	IF nId == 0
		(::cAlias)->( DbGoTop() )
	ELSEIF nId == ::nRegGrande	
		(::cAlias)->( DbGoBottom() )
		(::cAlias)->( DbSkip( -nRows ) )
		if (::cAlias)->( bof() )
			(::cAlias)->( DbGotop() )
		else
			(::cAlias)->( dbskip() )	
		end 	
	ELSE
		if nRows < 0
			(::cAlias)->( DbGoto( nId ) )
			(::cAlias)->( DbSkip( nRows ) )
			if (::cAlias)->( bof() )
				(::cAlias)->( dbgotop() )
			else
				( ::cAlias )->( dbskip( -1 ) )	
			end 
			nRows = abs( nRows )	
		else	
			(::cAlias)->( DbGoto( nId ) )
			(::cAlias)->( DbSkip() )
		end 	
	ENDIF
	
		WHILE nCount < nRows .AND. (::cAlias)->( !Eof() )
		
			nRecno := (::cAlias)->( Recno() )
		
			Aadd( hRows, { '_recno'	=> nRecno,;
							'id' 		=> (::cAlias)->id,;
							'fecha'		=> (::cAlias)->fecha,;
							'titulo'	=> (::cAlias)->titulo,;
							'texto' 	=> (::cAlias)->texto ;
						})						
		
			nCount++						
		
			(::cAlias)->( DbSkip(1) )
		END	
		
	
	
	hData[ 'recno' ] := nRecno
	hData[ 'rows'  ] := hRows

RETU hData

//	-----------------------------------------------


METHOD GetId( nId ) CLASS EntryModel

	LOCAL hRow 	:= {=>}
	
	DEFAULT nId TO 0
	
	(::cAlias)->( DbGoTo( nId ) )
	
	hRow  :=  { '_recno'	=> nId,;
				'id' 		=> (::cAlias)->id,;
				'fecha'		=> (::cAlias)->fecha,;
				'titulo'	=> (::cAlias)->titulo,;
				'texto' 	=> (::cAlias)->texto ;
				}		

RETU hRow