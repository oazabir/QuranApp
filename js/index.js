/// <reference path="sugar.js" />
/// <reference path="swiper.js" />
/// <reference path="jquery.mobile-1.4.5.min.js" />
/// <reference path="jquery-1.11.3.min.js" />
/// <reference path="fontspy.js" />
/// <reference path="jquery.cookie.js" />


jQuery.cachedScript = function (url, options) {

    // Allow user to set any option except for dataType, cache, and url
    options = $.extend(options || {}, {
        dataType: "script",
        cache: true,
        url: url + versionSuffix
    });

    // Use $.ajax() since it is more flexible than $.getScript
    // Return the jqXHR object so we can chain callbacks
    return jQuery.ajax(options);
};

function showDetails(key) {

    var meaning = window.wordbyword[key];
    if (meaning) {
        var popup = $('#meaningPopup');
        // pickup the template from saved location, if the html has been modified during last popup show
        var template = popup.data('template') || popup.html();
        popup.data('template', template);

        var output = template.assign(meaning, {
            textlink: 'http://www.almaany.com/en/dict/ar-en/' + meaning.t,
            lemmalink: 'http://www.almaany.com/en/dict/ar-en/' + meaning.l,
            rootsplit: meaning.r == "" ? "" : meaning.r[0] + ' ' + meaning.r[1] + ' ' + meaning.r[2] + ' ' + (meaning.r[3] || ""),
            rootlink: 'http://ejtaal.net/m/aa/#q=' + meaning.r + ',dhq=,mgf=,hw4=,pr=,ll=,ls=,mis=h,la=h,amr=h,auh=h,umr=h,ulq=h,uqa=h,uqq=h,sg=h,ha=h,mr=h,mn=h,kz=h,uqw=h,ums=h,umj=h,bdw=h,asb=h,mht=h,msb=h,tla=h,amj=h,ens=h,aan=h,vi=h'
        });

        popup.html(output).popup('open');
    }
}

function getCurrentSura() {
    var surahs = Object.values(window.surahs);
    var pageNo = getCurrentPageNo();
    var lastSura = surahs[0];
    var s = 0;
    while(s < surahs.length && surahs[s].p <= pageNo) {
        lastSura = surahs[s];
        s++;
    }
    return lastSura;
}

function loadSurahAyahMap() {
    if (!window.suraayahmap) {
        $.cachedScript('page/sura_ayah_map.js');
    }
}

$('#searchPopup').popup({
    afteropen: function (event, ui) {
        
        $('#gotoSurahAyahButton').one('click', function () {
            gotoSurahAyah($('#jumpTo').val());
        })
        $('#searchPopup .error').hide();

    }
});

function gotoSurahAyah(surahAyah) {
    if (window.suraayahmap) {
        var result = /(\d+).(\d+)/.exec(surahAyah);
        var sura = result[1];
        var ayah = result[2];

        var searchReg = new RegExp(',' + sura + ':' + ayah + '=(\\d+)', "g");
        var pageMatch = searchReg.exec(window.suraayahmap);
        if (pageMatch) {
            var pageNo = pageMatch[1];
            window.highlight = { sura: sura, ayah: ayah };
            $('#searchPopup').popup('close');
            slideToPage(pageNo);
        } else {
            $('#searchPopup .error').show();
        }
    } else {
        $('#searchPopup .error').show();
    }

}

function slideToPage(pageNo) {
    pageNo = parseInt(pageNo);

    // ensure the page is created, loaded
    loadPage(pageNo);

    // get the swiper slide index containing the page
    var pageDiv = getPageDiv(pageNo);
    var swiperDiv = pageDiv.parent();
    window.swiper.slideTo(swiperDiv.index());

}

function hideAllTooltips() {
    $('.tooltipstered').tooltipster('hide');
}

function highlightSurahAyah(highlight) {
    var h = highlight || window.highlight;
    if (h) {
        var template = '.word[sura="{sura}"][ayah="{ayah}"]';
        var nodes = $(template.assign(h));
        nodes.css('background-color', 'lightgreen');
        window.setTimeout(function () {
            nodes.css('background-color', '');
        }, 3000);
        window.highlight = null;
    }
}

function makeSwiperDiv(pageNo) {
    var pageStr = pageNo.pad(3);
    var template = '<div class="swiper-slide"><div class="page" id="page{pageStr}" pageno="{pageNo}"></div></div>';
    return $(template.assign({ pageStr: pageStr, pageNo: pageNo }));
}

function getSwiperDiv(pageNo) {
    var pageDiv = getPageDiv(pageNo);
    var swiper = pageDiv.parent();
    return swiper;
}

function getPageDiv(pageNo) {
    var pageStr = "000" + pageNo;
    pageStr = pageStr.substr(pageStr.length - 3);
    return $('#page' + pageStr);
}

function buildAyahNumberTooltip(ayahMark, sura, ayah, isBookmarked) {
    var key = sura + ":" + ayah;
    var translation = window.translation[key];

    ayahMark.tooltipster().tooltipster('destroy');

    var template = '<div> \
                        <div class="bangla_meaning">{b}</div> \
                        <div class="english_meaning">({key}) {e}</div> \
                        </div>';
    var output = template.assign(translation, { key: key });
    
    ayahMark.tooltipster({
        contentAsHTML: true,
        content: output,
        delay: 200
    });

    if (isBookmarked) {
        ayahMark.addClass('bookmarked_ayah');
    } else {

    }

    var actionsTemplate = '<div id="ayah_actions"> \
                    <a href="#bookmarkPopup" class="{bookmarked}" id="bookmark_ayah" sura="{sura}" ayah="{ayah}" onclick="toggleAyahBookmark()">&#x1f516;</a> \
                    <a href="#" id="translation_ayah" sura="{sura}" ayah="{ayah}" onclick="showTranslationAyah()">&#x1f4d6;</a> \
                    </div>';
    var actionContent = actionsTemplate.assign({ sura: sura, ayah: ayah, bookmarked: isBookmarked ? 'bookmarked_ayah' : '' });
    ayahMark.tooltipster({
        contentAsHTML: true,
        interactive: true,
        content: actionContent,
        multiple: true,
        position: 'right',
        delay: 200
    });
}

function loadPage(pageNo) {
    pageNo = parseInt("" + pageNo);
    var pageStr = "000" + pageNo;
    pageStr = pageStr.substr(pageStr.length - 3);

    var pageDivId = '#page' + pageStr;


    function postContentLoad() {
        $.cookie('page', pageNo, { path: '/', expires: 30 });
        $.mobile.loading('hide');
        highlightSurahAyah();
        hideAllTooltips();
        pageDiv.attr("status", "loaded");
    }
    // ensure the page div is there. if not, then create that page div and one before and after.
    var pageDiv = $(pageDivId);
    if (pageDiv.length == 0) {
        swiperDiv = makeSwiperDiv(pageNo);

        var before = getPageDiv(pageNo - 1);
        var after = getPageDiv(pageNo + 1);

        if (before.length > 0) {
            swiperDiv.insertAfter(before.parent());
        } else if (after.length > 0) {
            swiperDiv.insertBefore(after.parent());
        } else {
            // before and after nothing exists. find the highest page div which is before this page and insert after that page
            var lastPageNo = 1;
            $('div.page').each(function (i, e) {
                var thisPageNo = parseInt($(e).attr("pageno"));
                if (thisPageNo < pageNo)
                    lastPageNo = thisPageNo;
            })
            var lastPageDiv = getPageDiv(lastPageNo);
            swiperDiv.insertAfter(lastPageDiv.parent());
        }

        window.swiper.update(true);
    }

    // get the newly created div or existing div
    pageDiv = getPageDiv(pageNo);

    // ensure a page slide exists before this page
    if (pageNo > 1) {
        var before = getPageDiv(pageNo - 1);
        if (before.length == 0) {
            before = makeSwiperDiv(pageNo - 1);
            before.insertBefore(pageDiv.parent());
            window.swiper.activeIndex++; // current slide will be pushed by one slide
            window.swiper.update(true);
        }
    }
    // ensure a page slide exists after this page
    if (pageNo < 604) {
        var after = getPageDiv(pageNo + 1);
        if (after.length == 0) {
            after = makeSwiperDiv(pageNo + 1);
            after.insertAfter(pageDiv.parent());
            window.swiper.update(true);
        }
    }

    // if page is already loading/loaded, nothing to do
    if (pageDiv.attr("status") == "loading" || pageDiv.attr("status") == "loaded") {
        postContentLoad();
        return;
    }
    pageDiv.attr("status", "loading");

    $.mobile.loading('show');
    $.ajaxSetup({ cache: true });

    $.get('page/page' + pageStr + '.html' + versionSuffix, function (response) {

        var template = '<style type="text/css"> \
					@font-face { \
					 font-family: "page{pageStr}"; \
					 src: url("./data/fonts/QCF_P{pageStr}.woff") format("woff"); \
					 font-weight: normal; \
					 font-style: normal; \
					} \
					.page{pageStr} { font-family: "page{pageStr}"; } \
				</style>';
        var output = template.assign({ pageStr: pageStr });
        $(output).appendTo("head");

        pageDiv.html(response);

        $.cachedScript('page/page' + pageStr + '.js').done(function () {

            var wordBookmarks = BookmarkManager.getWordBookmarks();

            $(pageDivId + " .word").each(function (i, e) {
                var sura = $(this).attr("sura");
                var ayah = $(this).attr("ayah");
                var word = $(this).attr("word");
                var bookmark = wordBookmarks.find(function (b) { return b.sura == sura && b.ayah == ayah && b.word == word; })
                var isBookmarked = bookmark != null;
                if (isBookmarked) {
                    $(this).addClass('bookmarked_word');
                    $(this).attr('bookmarked', true);
                }

                $(this).tooltipster({
                    contentAsHTML: true,
                    interactive: true,
                    delay: 200,

                    functionBefore: function (origin, continueTooltip) {
                        var sura = $(this).attr("sura");
                        var ayah = $(this).attr("ayah");
                        var word = $(this).attr("word");
                        var isBookmarked = $(this).attr('bookmarked');
                        
                        var key = sura + ":" + ayah + ":" + word;
                        var meaning = window.wordbyword[key];

                        if (meaning) {
                            var template = '<div> \
                        <div class="tooltip_actions"> \
                        <a href="#bookmarkPopup" class="{bookmarkedClass}" bookmarked="{isBookmarked}" id="bookmark_word" sura="{sura}" ayah="{ayah}" word="{word}" onclick="toggleWordBookmark()">&#x1f516;</a> \
                        <a href="#meaningPopup" data-rel="popup" onclick="hideAllTooltips(); showDetails(\'{key}\')" id="meaningDetails" class="meaning_details" >&#x1f50d;</a> \
                        </div> \
                        <span class="arabic_word">{t}</span> <span class="transliteration">{tl}</span> <span class="root">{root}</span> \
                        <div> \
                        <span class="bangla_meaning">{b}</span> \
                        <span class="english_meaning">{e}</span> \
                        <span class="indonesia_meaning">{i}</span> \
                        </div> \
                        <div><span class="lemma">Lemma এসেছে <span>{l}</span> থেকে।</span> \
                        <span class="lemma_meaning">এর অর্থ: <span>{lb}</span></span></div> \
                        </div>';
                            var root = meaning.r ? meaning.r[0] + ' ' + meaning.r[1] + ' ' + meaning.r[2] + ' ' + (meaning.r[3] || "") : "";
                            
                            var output = template.assign(meaning, {
                                root: root,
                                sura: sura, ayah: ayah, word: word,
                                pageDivId: pageDivId, key: key,
                                isBookmarked: isBookmarked,
                                bookmarkedClass: isBookmarked ? 'bookmarked_word' : ''
                            });
                            origin.tooltipster("content", $(output));
                            continueTooltip();
                        }
                    }
                
                });
                
            });

            var bookmarkedAyat = BookmarkManager.getAyahBookmarks();
            
            $(pageDivId + " .ayah_number").each(function (i, e) {
                var ayahMark = $(this);
                var sura = ayahMark.attr("sura");
                var ayah = ayahMark.attr("ayah");
                var bookmark = bookmarkedAyat.find(function (b) { return b.sura == sura && b.ayah == ayah });

                buildAyahNumberTooltip(ayahMark, sura, ayah, bookmark != null);
            });
        });
        
        // When clicked on ayah bookmark:
        // 1. Add the ayah in the bookmark, or remove it.        
        // 3. Make the ayah number show (un)bookmarked color.
        // 4. Change the tooltip to show (un)bookmarked bookmark icon.
        // 5. Hide the tooltip
        window.toggleAyahBookmark = function (event) {
            var e = jQuery.event.fix(event || window.event);
            var link = $(e.target);

            var sura = link.attr("sura");
            var ayah = link.attr("ayah");
            
            var pageDiv = getPageDiv(getCurrentPageNo());
            var ayahNumber = pageDiv.find(".ayah_number[sura='" + sura + "'][ayah='" + ayah + "']");
            ayahNumber.tooltipster('hide');
            
            var bookmarkAdded = BookmarkManager.toggleAyahBookmark(sura, ayah);
            if (bookmarkAdded) {
                ayahNumber.addClass('bookmarked_ayah');
                link.addClass('bookmarked_ayah');
                ayahNumber.attr('bookmarked', true);
            } else {
                ayahNumber.removeClass('bookmarked_ayah');
                link.removeClass('bookmarked_ayah');
                ayahNumber.attr('bookmarked', false);
            }

            buildAyahNumberTooltip(ayahNumber, sura, ayah, bookmarkAdded);
            jQueryMobileHack();
        }

        window.showTranslationAyah = function () {
            var e = jQuery.event.fix(event || window.event);
            var link = $(e.target);

            var sura = link.attr("sura");
            var ayah = link.attr("ayah");
            window.translationJump = { sura: sura, ayah: ayah };

            $('#translationPopup').popup('open', { positionTo: '#pagejumpbutton' });
            return true;
        }

        // When clicked on ayah bookmark:
        // 1. Add the word in the bookmark, or remove it.        
        // 3. Make the word show (un)bookmarked color.
        // 5. Hide the tooltip
        window.toggleWordBookmark = function (event) {
            var e = jQuery.event.fix(event || window.event);
            var link = $(e.target);

            var sura = link.attr("sura");
            var ayah = link.attr("ayah");
            var wordNo = link.attr("word");

            var pageDiv = getPageDiv(getCurrentPageNo());
            var word = pageDiv.find(".word[sura='" + sura + "'][ayah='" + ayah + "'][word='" + wordNo + "']");
            word.tooltipster('hide');

            var bookmarkAdded = BookmarkManager.toggleWordBookmark(sura, ayah, wordNo);
            if (bookmarkAdded) {
                word.addClass('bookmarked_word');
                link.addClass('bookmarked_word');
                word.attr('bookmarked', true);
            } else {
                word.removeClass('bookmarked_word');
                link.removeClass('bookmarked_word');
                word.attr('bookmarked', false);
            }
            jQueryMobileHack();
        }

        var firstChar = $(pageDivId + ' .word').first().text(); //.charCodeAt(0).toString(16);
        var fontName = "page" + pageStr;
        fontSpy(fontName, {
            timeOut: 30000,
            delay: 100,
            glyphs: firstChar,
            success: function () {

                // After the font is loaded, calculate size of all word. if some word are
                // smaller than 5px width, then those are tajweed symbol, which aren't really
                // actual word in an ayah. So, we need to reset the word number ignoring those
                // symbols.
                //var wordNo; var lastAyah;
                //$(pageDivId + ' .line').each(function (i, line) {
                //    $(line).find('span.word').each(function (i, word) {
                //        if (lastAyah != $(word).attr("ayah")) {
                //            wordNo = 1;
                //        }
                //        lastAyah = $(word).attr("ayah");
                //        if ($(word).width() > 5) {
                //            $(word).attr("word", wordNo++);
                //        }
                //    })
                //});

                postContentLoad();
            },
            failure: function () {
                alert("Unable to download arabic font for this page. You may not be connected to the Internet, or your mobile is just too old.");
            }
        });

    }, 'html');
}

function getCurrentPageNo() {
    var swiperDiv = swiper.slides[swiper.activeIndex];
    var pageNo = parseInt($(swiperDiv).find('div.page').attr('pageno'));
    return pageNo;
}


$(document).ready(function () {
    window.swiper = new Swiper('.swiper-container', {
        nextButton: '.swiper-button-next',
        prevButton: '.swiper-button-prev',
        slidesPerView: 1,
        centeredSlides: false,
        scrollbar: '.swiper-scrollbar',
        scrollbarHide: false,
        spaceBetween: 0,
        //loop: true ,
        onSlideChangeStart: function(swiper) {
            hideAllTooltips();
        },
        onSlideChangeEnd: function (swiper) {
            pageNo = getCurrentPageNo();
            loadPage(pageNo);
        },
        onInit: function (swiper) {
            window.setTimeout(function () {
                var page = parseInt($.cookie('page'));
                if (isNaN(page)) {
                    page = 1;
                }
                slideToPage(page);
            }, 500)
        }
    });
});

$('#pagejumppanel').on("popupafteropen", function (event) {
    loadSurahAyahMap();
    $('#pagenumberToJump').val(getCurrentPageNo()).focus().textinput('refresh');
});
$('#translationPopup').on("popupbeforeposition", function (event) {
    var maxHeight = $(window).height() - 30;
    //$(this).css('height', (maxHeight * 0.4) + "px");
});

$('#translationPopup').on("popupafteropen", function (event) {
    var pageNo = getCurrentPageNo();
    var url = "page/bangla" + (pageNo.pad(3)) + ".html";
    var contentArea = $('#translationContent');
    
    contentArea.load(url, function () {
        var firstWord = getPageDiv(pageNo).find('.word').first();
        var suraNo = firstWord.attr('sura');
        var ayahNo = firstWord.attr('ayah');

        if (window.translationJump) {
            suraNo = window.translationJump.sura;
            ayahNo = window.translationJump.ayah;
            window.translationJump = null;
        }
        
        var ayahBookmark = $('#translationContent a[name="' + suraNo + ':' + ayahNo + '"]');
        var verseP = ayahBookmark.parent();
        var scrollY = ayahBookmark.offset().top - contentArea.offset().top - 15 * 2;
        contentArea.scrollTop(scrollY);

        verseP.addClass('highlighted');
        window.setTimeout(function () {
            verseP.removeClass('highlighted');
        }, 3000);

    });
    
    
});

var BookmarkManager = {
    pageBoomarksName : "pageBookmarks",
    ayahBookmarksName : "ayahBookmarks",
    wordBookmarksName: "wordBookmarks",

    getAyahBookmarks: function() {
        var storeName = BookmarkManager.getStoreName(1);
        var bookmarks = BookmarkManager.getLocalStorageObject(storeName) || [];

        return bookmarks;//.exclude(function (b) { return b.page != pageNo });
    },

    getWordBookmarks: function () {
        var storeName = BookmarkManager.getStoreName(2);
        var bookmarks = BookmarkManager.getLocalStorageObject(storeName) || [];

        return bookmarks; //.exclude(function (b) { return b.page != pageNo });
    },

    clearBookmarks: function () {
        BookmarkManager.saveLocalStorageObject(pageBoomarksName, null);
        BookmarkManager.saveLocalStorageObject(ayahBookmarksName, null);
        BookmarkManager.saveLocalStorageObject(wordBookmarksName, null);

        BookmarkManager.refreshListViews();
    },

    refreshListViews: function () {
        $('#addPageBookmark').off('click').on('click', function () {
            BookmarkManager.addPageBookmark();
        }).show();

        BookmarkManager.populateListView(BookmarkManager.pageBoomarksName, '#pageBookmarkListView', BookmarkManager.pageBookmarkRender);
        BookmarkManager.populateListView(BookmarkManager.ayahBookmarksName, '#ayahBookmarkListView', BookmarkManager.ayahBookmarkRender);
        BookmarkManager.populateListView(BookmarkManager.wordBookmarksName, '#wordBookmarkListView', BookmarkManager.wordBookmarkRender);
    },

    getLocalStorageObject: function (name) {
        var json = localStorage.getItem(name);
        if (json) {
            try {
                var bookmarks = JSON.parse(json);
                return bookmarks;
            } catch (e) {
                if (console) { console.log(e); }
                return null;
            }

        }
    },

    getStoreName: function (type) {
        return type == 0 ? BookmarkManager.pageBoomarksName :
                type == 1 ? BookmarkManager.ayahBookmarksName :
                    BookmarkManager.wordBookmarksName;
    },

    addPageBookmark: function () {
        var sura = getCurrentSura();
        var pageNo = getCurrentPageNo();

        var firstWord = getPageDiv(pageNo).find('.word').first();
        var suraNo = firstWord.attr('sura');
        var ayahNo = firstWord.attr('ayah');

        var storeName = BookmarkManager.getStoreName(0);
        var bookmarks = BookmarkManager.getLocalStorageObject(storeName) || [];
        var id = bookmarks.length;
        var translation = window.translation[suraNo + ':' + ayahNo];

        var newBookmark = {
            id: id,
            sura: suraNo,
            ayah: ayahNo,
            page: pageNo,
            type: 0,
            ayahText: translation.t,
            surahName1: sura.e,
            surahName2: sura.b,
            surahName: sura.a,            
        };

        bookmarks.push(newBookmark);

        BookmarkManager.saveLocalStorageObject(storeName, bookmarks);

        BookmarkManager.refreshListViews();
    },

    toggleAyahBookmark: function (suraNo, ayahNo) {
        var sura = getCurrentSura();
        var pageNo = getCurrentPageNo();

        var storeName = BookmarkManager.getStoreName(1);
        var bookmarks = BookmarkManager.getLocalStorageObject(storeName) || [];
        var id = bookmarks.length;
        var translation = window.translation[suraNo + ':' + ayahNo];

        var newBookmarks = bookmarks.exclude(function (b) { return b.sura == suraNo && b.ayah == ayahNo; });
        if (newBookmarks.length == bookmarks.length) {

            var newBookmark = {
                id: id,
                sura: suraNo,
                ayah: ayahNo,
                page: pageNo,
                type: 1,
                ayahText: translation.t,
                surahName1: sura.e,
                surahName2: sura.b,
                surahName: sura.a,
            };

            bookmarks.push(newBookmark);
            BookmarkManager.saveLocalStorageObject(storeName, bookmarks);
            BookmarkManager.refreshListViews();
            return true;
        } else {
            BookmarkManager.saveLocalStorageObject(storeName, newBookmarks);
            BookmarkManager.refreshListViews();
            return false;
        }        
    },

    toggleWordBookmark: function (suraNo, ayahNo, wordNo) {
        var sura = getCurrentSura();
        var pageNo = getCurrentPageNo();

        var storeName = BookmarkManager.getStoreName(2);
        var bookmarks = BookmarkManager.getLocalStorageObject(storeName) || [];
        var id = bookmarks.length;
        var translation = window.translation[suraNo + ':' + ayahNo];
        var key = suraNo + ':' + ayahNo + ':' + wordNo;
        var meaning = window.wordbyword[key];
        var newBookmarks = bookmarks.exclude(function (b) { return b.sura == suraNo && b.ayah == ayahNo && b.word == wordNo; });
        if (newBookmarks.length == bookmarks.length) {
            var newBookmark = {
                id: id,
                sura: suraNo,
                ayah: ayahNo,
                word: wordNo, 
                page: pageNo,
                type: 2,
                ayahText: translation.t,
                surahName1: sura.e,
                surahName2: sura.b,
                surahName: sura.a,
                arabicWord: meaning.t,
                word1: meaning.e,
                word2: meaning.b
            };

            bookmarks.push(newBookmark);
            BookmarkManager.saveLocalStorageObject(storeName, bookmarks);
            BookmarkManager.refreshListViews();
            return true;
        } else {
            BookmarkManager.saveLocalStorageObject(storeName, newBookmarks);
            BookmarkManager.refreshListViews();
            return false;
        }
    },

    saveLocalStorageObject: function(name, item) {
        var json = JSON.stringify(item);
        localStorage.setItem(name, json);
    },

    pageBookmarkRender: function (bookmark) {
        var template = '<span>{sura}:{ayah}</span>' +
                    '<span>{surahName1}</span>' +
                    '<span>{surahName2}</span>' +
                    '<span class="bookmark-surahname">{surahName}</span>' +
                    '<div class="ayah-snippet">{ayahText}</div>' +
                    '<span class="ui-li-count">{page}</span>';
        return template.assign(bookmark);
    },

    ayahBookmarkRender: function (bookmark) {
        return BookmarkManager.pageBookmarkRender(bookmark);
    },

    wordBookmarkRender: function (bookmark) {
        var template = '<span class="arabic">{arabicWord}</span>' +
                '<span>{word1}</span>' +
                '<span>{word2}</span>' +
                '<span>{sura}:{ayah}</span>' +
                '<div class="ayah-snippet">{ayahText}</div>' +
                '<span class="ui-li-count">{page}</span>';
        return template.assign(bookmark);
    },

    deleteBookmark: function (type, id) {
        var storeName = BookmarkManager.getStoreName(type);
        var bookmarks = BookmarkManager.getLocalStorageObject(storeName);
        var newBookmarks = bookmarks.exclude(function (b) { return b.id == id });
        BookmarkManager.saveLocalStorageObject(storeName, newBookmarks);
        BookmarkManager.refreshListViews();
    },    

    populateListView: function (storeName, listviewid, itemCallback) {
        var bookmarks = BookmarkManager.getLocalStorageObject(storeName) || [];
        var bookmarkListView = $(listviewid);
        bookmarkListView.find('li').remove();
        var currentPage = getCurrentPageNo();

        for (var i = bookmarks.length - 1; i >= 0; i--) {
            var bookmark = bookmarks[i];

            if (bookmark.type == 0 && bookmark.page == currentPage) {
                $('#addPageBookmark').hide();
            }

            var template = '<li data-icon="none"><a class="pageJumpLink" href="#" sura="{sura}" ayah="{ayah}" data-rel="back">{content}</a> \
                        <a class="ui-btn-icon-right ui-icon-delete" href="#" type="{type}" bookmarkid="{id}"></a></li>';
            var li = $(template.assign(bookmark, {content: itemCallback(bookmark)}));
            li.appendTo(bookmarkListView);

            li.find('a.ui-icon-delete').click(function () {
                BookmarkManager.deleteBookmark($(this).attr("type"), $(this).attr("bookmarkid"));
            });
            li.find('a.pageJumpLink').click(function () {
                gotoSurahAyah($(this).attr("sura") + ":" + $(this).attr("ayah"));
            });
        }
        bookmarkListView.listview('refresh');
    }
};

$('#bookmarkPopup').on("popupafteropen", function (event) {
    
    loadSurahAyahMap();
    BookmarkManager.refreshListViews();

});



function jQueryMobileHack() {
    // this is to prevent a bug in jquery mobile.
    document.documentElement.focus();
}


function updateSurahPanel() {
    var sura = getCurrentSura();
    $("#surahpanel select")[0].selectedIndex = sura.s - 1;
    $("#surahpanel select").selectmenu('refresh');
}

$('#home').on("pagecreate", function (event) {

    $('#surahpanel select').bind("change", function (event, ui) {
        var suraNo = parseInt($(this).val());
        var sura = window.surahs["surah" + suraNo];
        slideToPage(sura.p);
    });

    $("#surahpanel").on("panelbeforeopen", function () {
        updateSurahPanel();       
    });
    
    jQueryMobileHack();
});

$.mobile.popup.prototype.options.history = false;

