/* jquery hotkeys 0.7.9 */
(function(jQuery){jQuery.fn.__bind__=jQuery.fn.bind;jQuery.fn.__unbind__=jQuery.fn.unbind;jQuery.fn.__find__=jQuery.fn.find;var hotkeys={version:'0.7.9',override:/keypress|keydown|keyup/g,triggersMap:{},specialKeys:{27:'esc',9:'tab',32:'space',13:'return',8:'backspace',145:'scroll',20:'capslock',144:'numlock',19:'pause',45:'insert',36:'home',46:'del',35:'end',33:'pageup',34:'pagedown',37:'left',38:'up',39:'right',40:'down',109:'-',112:'f1',113:'f2',114:'f3',115:'f4',116:'f5',117:'f6',118:'f7',119:'f8',120:'f9',121:'f10',122:'f11',123:'f12',191:'/'},shiftNums:{"`":"~","1":"!","2":"@","3":"#","4":"$","5":"%","6":"^","7":"&","8":"*","9":"(","0":")","-":"_","=":"+",";":":","'":"\"",",":"<",".":">","/":"?","\\":"|"},newTrigger:function(type,combi,callback){var result={};result[type]={};result[type][combi]={cb:callback,disableInInput:false};return result;}};hotkeys.specialKeys=jQuery.extend(hotkeys.specialKeys,{96:'0',97:'1',98:'2',99:'3',100:'4',101:'5',102:'6',103:'7',104:'8',105:'9',106:'*',107:'+',109:'-',110:'.',111:'/'});jQuery.fn.find=function(selector){this.query=selector;return jQuery.fn.__find__.apply(this,arguments);};jQuery.fn.unbind=function(type,combi,fn){if(jQuery.isFunction(combi)){fn=combi;combi=null;}
if(combi&&typeof combi==='string'){var selectorId=((this.prevObject&&this.prevObject.query)||(this[0].id&&this[0].id)||this[0]).toString();var hkTypes=type.split(' ');for(var x=0;x<hkTypes.length;x++){delete hotkeys.triggersMap[selectorId][hkTypes[x]][combi];}}
return this.__unbind__(type,fn);};jQuery.fn.bind=function(type,data,fn){var handle=type.match(hotkeys.override);if(jQuery.isFunction(data)||!handle){return this.__bind__(type,data,fn);}
else{var result=null,pass2jq=jQuery.trim(type.replace(hotkeys.override,''));if(pass2jq){result=this.__bind__(pass2jq,data,fn);}
if(typeof data==="string"){data={'combi':data};}
if(data.combi){for(var x=0;x<handle.length;x++){var eventType=handle[x];var combi=data.combi.toLowerCase(),trigger=hotkeys.newTrigger(eventType,combi,fn),selectorId=((this.prevObject&&this.prevObject.query)||(this[0].id&&this[0].id)||this[0]).toString();trigger[eventType][combi].disableInInput=data.disableInInput;if(!hotkeys.triggersMap[selectorId]){hotkeys.triggersMap[selectorId]=trigger;}
else if(!hotkeys.triggersMap[selectorId][eventType]){hotkeys.triggersMap[selectorId][eventType]=trigger[eventType];}
var mapPoint=hotkeys.triggersMap[selectorId][eventType][combi];if(!mapPoint){hotkeys.triggersMap[selectorId][eventType][combi]=[trigger[eventType][combi]];}
else if(mapPoint.constructor!==Array){hotkeys.triggersMap[selectorId][eventType][combi]=[mapPoint];}
else{hotkeys.triggersMap[selectorId][eventType][combi][mapPoint.length]=trigger[eventType][combi];}
this.each(function(){var jqElem=jQuery(this);if(jqElem.attr('hkId')&&jqElem.attr('hkId')!==selectorId){selectorId=jqElem.attr('hkId')+";"+selectorId;}
jqElem.attr('hkId',selectorId);});result=this.__bind__(handle.join(' '),data,hotkeys.handler)}}
return result;}};hotkeys.findElement=function(elem){if(!jQuery(elem).attr('hkId')){if(jQuery.browser.opera||jQuery.browser.safari){while(!jQuery(elem).attr('hkId')&&elem.parentNode){elem=elem.parentNode;}}}
return elem;};hotkeys.handler=function(event){var target=hotkeys.findElement(event.currentTarget),jTarget=jQuery(target),ids=jTarget.attr('hkId');if(ids){ids=ids.split(';');var code=event.which,type=event.type,special=hotkeys.specialKeys[code],character=!special&&String.fromCharCode(code).toLowerCase(),shift=event.shiftKey,ctrl=event.ctrlKey,alt=event.altKey||event.originalEvent.altKey,mapPoint=null;for(var x=0;x<ids.length;x++){if(hotkeys.triggersMap[ids[x]][type]){mapPoint=hotkeys.triggersMap[ids[x]][type];break;}}
if(mapPoint){var trigger;if(!shift&&!ctrl&&!alt){trigger=mapPoint[special]||(character&&mapPoint[character]);}
else{var modif='';if(alt)modif+='alt+';if(ctrl)modif+='ctrl+';if(shift)modif+='shift+';trigger=mapPoint[modif+special];if(!trigger){if(character){trigger=mapPoint[modif+character]||mapPoint[modif+hotkeys.shiftNums[character]]||(modif==='shift+'&&mapPoint[hotkeys.shiftNums[character]]);}}}
if(trigger){var result=false;for(var x=0;x<trigger.length;x++){if(trigger[x].disableInInput){var elem=jQuery(event.target);if(jTarget.is("input")||jTarget.is("textarea")||jTarget.is("select")||elem.is("input")||elem.is("textarea")||elem.is("select")){return true;}}
result=result||trigger[x].cb.apply(this,[event]);}
return result;}}}};window.hotkeys=hotkeys;return jQuery;})(jQuery);

var IIJO = {
   focusOnStuff : function () {
      if($("#loginForm"   ).length) { $('input#username').focus() }
      if($("#registerForm").length) { $('input#username').focus() }
      if($("#search"      ).length) { $('input#isearch' ).focus() }
   },
   encodeUtf8  : function(s) { return unescape(encodeURIComponent(s)) },
   decodeUtf8  : function(s) { return decodeURIComponent(escape(s))   },
   HotKeys : {
      addCards    : function() { window.location.href = $("a#add"     ).attr('href') },
      test        : function() { window.location.href = $("a#test"    ).attr('href') },
      practice    : function() { window.location.href = $("a#practice").attr('href') },
      viewSet     : function() { window.location.href = $("a#view"    ).attr('href') },
      edit        : function() { window.location.href = $("a#edit"    ).attr('href') },
      exportWords : function() { window.location.href = $("a#export"  ).attr('href') },
      showAnswer  : function() { $("form#show" ).submit(); return false; },
      wrongAnswer : function() { $("form#wrong").submit(); return false; },
      rightAnswer : function() { $("form#right").submit(); return false; },
      bindings    : function() {
         if($("a#add"     ).length) { $(document).bind('keydown', 'alt+a', IIJO.HotKeys.addCards) }
         if($("a#edit"    ).length) { $(document).bind('keydown', 'alt+i', IIJO.HotKeys.edit) }
         if($("a#export"  ).length) { $(document).bind('keydown', 'alt+o', IIJO.HotKeys.exportWords) }
         if($("a#practice").length) { $(document).bind('keydown', 'alt+p', IIJO.HotKeys.practice) }
         if($("a#test"    ).length) { $(document).bind('keydown', 'alt+t', IIJO.HotKeys.test) }
         if($("a#view"    ).length) { $(document).bind('keydown', 'alt+v', IIJO.HotKeys.viewSet) }
         if($("form#show" ).length) { IIJO.HotKeys.bindAskButtons() }
         if($("form#right").length) { IIJO.HotKeys.bindAnswerButtons() }
      },
      bindAskButtons : function() {
         $(document).bind('keydown', 'space', IIJO.HotKeys.showAnswer);
         $(document).bind('keydown', 'alt+s', IIJO.HotKeys.showAnswer);
         $(document).bind('keydown', 's',     IIJO.HotKeys.showAnswer);
      },
      bindAnswerButtons : function() {
         $(document).bind('keydown', 'alt+r', IIJO.HotKeys.rightAnswer);
         $(document).bind('keydown', 'r',     IIJO.HotKeys.rightAnswer);
         $(document).bind('keydown', 'alt+w', IIJO.HotKeys.wrongAnswer);
         $(document).bind('keydown', 'w',     IIJO.HotKeys.wrongAnswer);
      }
   },

   FlashCards : {
      cardsLeft    : 0,
      totalCards   : 0,
      pctComplete  : 0,
      baseURL      : '',
      card         : {},
      nextCard     : {},
      loadFromHTML : function() {
         IIJO.FlashCards.cardsLeft   = $("input#hCardsLeft"  ).val();
         IIJO.FlashCards.totalCards  = $("input#hTotalCards" ).val();
         IIJO.FlashCards.pctComplete = $("input#hPctComplete").val();
         IIJO.FlashCards.card = {
            cardId           : $("input#hCardId"      ).val(),
            definitionId     : $("input#hDefinitionId").val(),
            baseURL          : $("input#hBaseURL"     ).val(),
            difficulty       : $("input#hDifficulty"  ).val(),
            english          : decodeURIComponent($("input#hEnglish"   ).val()),
            pinyin           : decodeURIComponent($("input#hPinyin"    ).val()),
            simplified       : decodeURIComponent($("input#hSimplified").val()),
            englishAnswer    : decodeURIComponent($("input#hEnglishAnswer"   ).val()),
            pinyinAnswer     : decodeURIComponent($("input#hPinyinAnswer"    ).val()),
            simplifiedAnswer : decodeURIComponent($("input#hSimplifiedAnswer").val()) 
         };
         $("form#show").submit(IIJO.FlashCards.showAnswer);
         $("form#right").submit(IIJO.FlashCards.rightAnswer);
         $("form#wrong").submit(IIJO.FlashCards.wrongAnswer);
         IIJO.FlashCards.next();
      },
      calculateCardsLeft : function(cardsLeft) {
         return cardsLeft - 1;
      },
      calculatePctComplete : function(totalCards, cardsLeft) {
         return (((totalCards - cardsLeft) / totalCards) * 100).toString().substring(0,4) + '%';
      },
      loadFromJSON : function(data, textStatus) {
         IIJO.FlashCards.nextCard = data;

         IIJO.FlashCards.nextCard.done = 0;
         if (IIJO.FlashCards.nextCard.cardsLeft <= 0 || data.english == undefined) {
           IIJO.FlashCards.nextCard.done = 1;
         }
      },
      advance : function() {
         var thisCard = IIJO.FlashCards.card;
         var nextCard = IIJO.FlashCards.nextCard;
         thisCard.cardId           = nextCard.cardId;
         thisCard.definitionId     = nextCard.definitionId;
         thisCard.baseURL          = nextCard.baseURL;
         thisCard.difficulty       = nextCard.difficulty;
         thisCard.english          = IIJO.decodeUtf8(nextCard.english);
         thisCard.pinyin           = IIJO.decodeUtf8(nextCard.pinyin);
         thisCard.simplified       = IIJO.decodeUtf8(nextCard.simplified);
         thisCard.englishAnswer    = IIJO.decodeUtf8(nextCard.englishAnswer);
         thisCard.pinyinAnswer     = IIJO.decodeUtf8(nextCard.pinyinAnswer);
         thisCard.simplifiedAnswer = IIJO.decodeUtf8(nextCard.simplifiedAnswer);
         thisCard.totalCards       = nextCard.totalCards;
         thisCard.cardsLeft        = IIJO.FlashCards.calculateCardsLeft(nextCard.cardsLeft);
         thisCard.pctComplete      = IIJO.FlashCards.calculatePctComplete(nextCard.totalCards, thisCard.cardsLeft);
         thisCard.done             = nextCard.done;
      },
      next : function() {
         var baseURL      = IIJO.FlashCards.card.baseURL;
         var definitionId = IIJO.FlashCards.card.definitionId;
         $.getJSON(baseURL + definitionId + '/ask/json', IIJO.FlashCards.loadFromJSON);
      },
      showAnswer : function(e) {
         /* show answers */
         $("li.simplified").html(IIJO.FlashCards.card.simplifiedAnswer);
         $("li.pinyin"    ).html(IIJO.FlashCards.card.pinyinAnswer);
         $("li.english"   ).html(IIJO.FlashCards.card.englishAnswer);
     
         /* replace show answer button with right/wrong answer buttons */ 
         var baseURL = IIJO.FlashCards.card.baseURL;
         var cardId  = IIJO.FlashCards.card.cardId;
         $("button.ask"   ).css('display','none');
         $("button.answer").css('display','block');
         $("form#right").attr('action', baseURL + cardId + '/difficulty/1');
         $("form#wrong").attr('action', baseURL + cardId + '/difficulty/0');

         return false;
      },
      rightAnswer : function() {
         var baseURL = IIJO.FlashCards.card.baseURL;
         var cardId  = IIJO.FlashCards.card.cardId;
         $.post(baseURL + cardId + '/difficulty/1');
         IIJO.FlashCards.showQuestion();
         return false;
      },
      wrongAnswer : function() {
         var baseURL = IIJO.FlashCards.card.baseURL;
         var cardId  = IIJO.FlashCards.card.cardId;
         $.post(baseURL + cardId + '/difficulty/0');
         IIJO.FlashCards.showQuestion();
         return false;
      },
      showQuestion : function() {
         if (IIJO.FlashCards.card.done || IIJO.FlashCards.nextCard.done) {
            window.location = IIJO.FlashCards.card.baseURL + 'done';
            return false;
         }

         /* advance to the next card */
         IIJO.FlashCards.advance();

         /* show question */
         $("li.simplified"  ).html(IIJO.FlashCards.card.simplified);
         $("li.pinyin"      ).html(IIJO.FlashCards.card.pinyin);
         $("li.english"     ).html(IIJO.FlashCards.card.english);
/*       $("div#cardsLeft"  ).text(IIJO.FlashCards.cardsLeftString()); */
         $("div#pctComplete").text(IIJO.FlashCards.pctCompleteString());
         $("div#difficulty" ).text(IIJO.FlashCards.difficultyString()); 
      
         /* replace right/wrong answer buttons with show answer button */ 
         $("button.answer").css('display','none');
         $("form#show").attr('action', IIJO.FlashCards.card.baseURL + '/answer');
         $("button.ask").css('display','block');

         /* ask server for next card */
         IIJO.FlashCards.next();
      
         return false;
      },
      cardsLeftString : function() {
         return IIJO.FlashCards.card.cardsLeft + ' out of ' + IIJO.FlashCards.card.totalCards + ' flashcards left';
      },
      pctCompleteString : function() {
         return IIJO.FlashCards.card.pctComplete + ' complete';
      },
      difficultyString : function() {
         return 'this card has difficulty ' + IIJO.FlashCards.card.difficulty;
      }
   }
};
jQuery(function ($) {
   if ($("form#show").length) {
      IIJO.FlashCards.loadFromHTML();
   }
   IIJO.HotKeys.bindings();
   IIJO.focusOnStuff();
});
