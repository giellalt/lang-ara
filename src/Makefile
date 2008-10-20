

XFST = xfst #-utf8
LEXC = lexc #-utf8


# Source files


SRCS = ara-lex.txt #\
#	noun-ara-lex.txt verb-ara-lex.txt abbr-ara-lex.txt \
#	noun-ara-morph.txt verb-ara-morph.txt
#	acro-ara-lex.txt \
#	punct-ara-lex.txt prt-ara-lex.txt num-ara-lex.txt 



# Here we build the final generator , an inverted transducer of the analyzer.
# It is dependent upon ara.save; change to ara.fst if an xfst file is needed.

iara.fst: ../bin/iara.fst
../bin/iara.fst: ../bin/ara.save # ../bin/abbr.txt ../bin/syll2lat.fst ../bin/lat2syll.fst
	@echo
	@echo "*** Building the inverse iara.fst ***"
	@echo
	@printf "load ../bin/ara.save \n\
	invert net \n\
	save stack ../bin/iara.fst \n\
	quit \n" > ../tmp/iara-fst-script
	$(XFST) < ../tmp/iara-fst-script
	@rm -f ../tmp/iara-fst-script





# Here comes the part building the basic parser.
# **********************************************
#ara.fst: ../bin/ara.fst
#	 ../bin/ara.fst: ../bin/xfst-ara.bin ../bin/ara.save
#	@echo
#	@echo "*** Building the parser ara.fst ***"
#	@echo
#	@printf "read regex [[@\"../bin/ara.save\"] .o. \
#	[@\"../bin/xfst-ara.bin\"]] ; \n\
#	save stack ../bin/ara.fst \n\
#	quit \n" > ../tmp/ara-fst-script
#	$(XFST) < ../tmp/ara-fst-script
#	@rm -f ../tmp/ara-fst-script


# The first goal is to build ara-lex.save
# This goal depends on a bunch of lexicon files

ara.save: ../bin/ara.save
../bin/ara.save: $(SRCS)
	@echo
	@echo "*** Building ara.save ***" ;
	@echo
	@printf "read lexc < $(SRCS) \n\
	list C b t ṯ ǧ ḥ ḫ d ḏ r z s š ṣ ḍ ṭ ẓ ʿ ġ f q k l m n h w y ; \n\
	list V a i u ; \n\
	compile-replace lower \n\
	save stack ../bin/ara.save \n\
	quit \n" > ../tmp/ara-save-script
	$(XFST) < ../tmp/ara-save-script
	@rm -f ../tmp/ara-save-script



# Here we build xfst-ara.bin, the morphophonological component.
# This goal depends on xfst-ara.txt

#xfst-ara.bin: ../bin/xfst-ara.bin
#../bin/xfst-ara.bin: xfst-ara.txt
#	@echo
#	@echo "*** Building xfst-ara.bin ***" ;
#	@echo
#	@printf "source xfst-ara.txt \n\
#	save stack ../bin/xfst-ara.bin \n\
#	quit \n" > ../tmp/xfst-ara-script
#	$(XFST) < ../tmp/xfst-ara-script
#	@rm -f ../tmp/xfst-ara-script
#


#syll2lat.fst: ../bin/syll2lat.fst
#../bin/syll2lat.fst: ../bin/lat2syll.fst ../script/syll.xfst
#	@echo
#	@echo "*** Building the inverse syll2lat.fst ***"
#	@echo
#	@printf "load ../bin/lat2syll.fst \n\
#	invert net \n\
#	save stack ../bin/syll2lat.fst \n\
#	quit \n" > ../tmp/syll2lat-fst-script
#	$(XFST) < ../tmp/syll2lat-fst-script
#	@rm -f ../tmp/syll2lat-fst-script
#
#
#
#lat2syll.fst: ../bin/lat2syll.fst
#../bin/lat2syll.fst: ../script/syll.xfst
#	@echo
#	@echo "*** Building lat2syll.fst ***" ;
#	@echo
#	@printf "source ../script/syll.xfst \n\
#	save stack ../bin/lat2syll.fst \n\
#	quit \n" > ../tmp/lat2syll-ara-script
#	$(XFST) < ../tmp/lat2syll-ara-script
#	@rm -f ../tmp/lat2syll-ara-script


clean:
	@rm -f ../bin/*.bin ../bin/*.fst ../bin/*.save
