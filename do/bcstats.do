if ${run_bcstats} {
  bcstats, ///
      surveydata(${dataset}) ///
      bcdata(${bcdataset})   ///
      id(${id})              ///
      enumerator(${enum})    ///
      enumteam(${enumteam})  ///
      backchecker(${bcer})   ///
      bcteam(${bcerteam})    ///
      t1vars(${type1_17})    ///
      t2vars(${type2_17})    ///
      t3vars(${type3_17})    ///
      ttest(${ttest17})     ///
      keepbc(${bckeepbc})    ///
      keepsurvey(${bckeepsurvey}) ///
      reliability(${reliability17}) ///
      filename("${bcoutfile}") ///
      lower nosymbol trim showall ///
      replace
}