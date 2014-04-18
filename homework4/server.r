require(ggplot2)
require(tm)        # corpus
require(SnowballC) # stemming
require(wordcloud) # word cloud
require(shiny)

sotu_source <- DirSource(
  #directory = file.path("/Users/conorosullivan/Documents/FourthModule/visualization/4_hw/LOTR"),
  encoding = "UTF-8",     
  pattern = "*.txt",      
  recursive = FALSE,      
  ignore.case = FALSE)    
sotu_corpus <- Corpus(
  sotu_source, 
  readerControl = list(
    reader = readPlain, 
    language = "en"))   
sotu_corpus <- tm_map(sotu_corpus, function(x) iconv(x, to='UTF-8-MAC', sub='byte'))
sotu_corpus <- tm_map(sotu_corpus, tolower)
sotu_corpus <- tm_map(
  sotu_corpus, 
  removePunctuation,
  preserve_intra_word_dashes = TRUE)
sotu_corpus <- tm_map(
  sotu_corpus, 
  removeWords, 
  stopwords("english"))
sotu_tdm <- TermDocumentMatrix(sotu_corpus)
sotu_matrix <- as.matrix(sotu_tdm)
sotu_df <- data.frame(
  word = rownames(sotu_matrix), 
  freq = rowSums(sotu_matrix),
  stringsAsFactors = FALSE) 
sotu_df <- sotu_df[with(
  sotu_df, 
  order(freq, decreasing = TRUE)), ]
rownames(sotu_df) <- NULL
sotu_df<-na.omit(sotu_df)
sotu_df<-sotu_df[!sotu_df$word %in% c("said", 'will', 'now', 'like', 'one', 'come', 'came', 
                                      'upon', 'still', 'many', 'went', 'see', 'must', 'even',
                                      '<ad>', 'two', 'seemed', 'old', 'rings', 'back', 'away',
                                      'great'),]
sotu_df<-rbind(sotu_df[sotu_df$word %in% c("frodo", "sam", "gandalf", "lord", "dark", "aragorn", "pippin", 
                                           "little", "hobbits", "merry", "king", "night", "ring", "black", 
                                           "gollum", "trees", "gimli", "orcs", "grey", "legolas", "sun", "fear", 
                                           "stone", "voice", "mountains", "bilbo", "man", "towers", "faramir", 
                                           "nothing", "boromir", "sariman", "elves", "gondor", "world", "riders", 
                                           "enemy", "strider", "sword"),],
               sotu_df[205:nrow(sotu_df),])

create_wordcloud<-function(sotu_df, numWords) {
  show(wordcloud(
    sotu_df$word,
    sotu_df$freq,
    scale = c(5, .5),      # size of words
    min.freq = 10,          # drop infrequent
    colors=brewer.pal(8, "Dark2"),
    #max.words = 100,        # max words in plot
    max.words = numWords,
    random.order = FALSE))
}

### Create barplots

words<-rownames(sotu_matrix)
allbooks<-data.frame(words=words, book1=sotu_matrix[,1], 
                     book2=sotu_matrix[,2], book3=sotu_matrix[,3])
book1<-data.frame(words=words, freq=sotu_matrix[,1])
book2<-data.frame(words=words, freq=sotu_matrix[,2])
book3<-data.frame(words=words, freq=sotu_matrix[,3])
rownames(book1)<-NULL
rownames(book2)<-NULL
rownames(book3)<-NULL

bookdfs<-c(book1, book2, book3)

clean_books<-function(elt){
  
  elt <- elt[with(
    elt, 
    order(freq, decreasing = TRUE)), ]
  elt<-na.omit(elt)
  elt<-elt[!elt$word %in% c("said", 'will', 'now', 'like', 'one', 'come', 'came', 
                            'upon', 'still', 'many', 'went', 'see', 'must', 'even',
                            '<ad>', 'two', 'seemed', 'old', 'rings', 'back', 'away',
                            'great'),]
  elt<-rbind(elt[elt$word %in% c("frodo", "sam", "gandalf", "lord", "dark", "aragorn", "pippin", 
                                 "little", "hobbits", "merry", "king", "night", "ring", "black", 
                                 "gollum", "trees", "gimli", "orcs", "grey", "legolas", "sun", "fear", 
                                 "stone", "voice", "mountains", "bilbo", "man", "towers", "faramir", 
                                 "nothing", "boromir", "sariman", "elves", "gondor", "world", "riders", 
                                 "enemy", "strider", "sword"),],
             elt[205:nrow(elt),])
  elt
}
book1<-clean_books(book1)
book2<-clean_books(book2)
book3<-clean_books(book3)

barfreq<-function(x){
  y<-head(x, 10)
  y$words<-factor(y$words, 
                  levels = y$words, 
                  ordered = TRUE)
  y
}
book1bar<-barfreq(book1)
book2bar<-barfreq(book2)
book3bar<-barfreq(book3)
allbartable <- cbind(book1bar, book2bar, book3bar)
colnames(allbartable)[c(1,3,5)]<-c("Fellowship", "Two_Towers", "Return_of_King")
rownames(allbartable)<-c(1:10)
allbar<-rbind(book1bar, book2bar, book3bar)
allbar$book<-rep(c("Fellowship of the Ring", "The Two Towers", "Return of the King"), each=10)

create_barplot<-function(allbar, which_book) {
  p <- ggplot(allbar[allbar$book==which_book,], aes(x = words, y = freq)) +
    geom_bar(stat = "identity", fill = "grey60") +
    facet_wrap( ~ book) +
    ggtitle("Lord of the Rings, Books 1 - 3") +
    xlab("Top 10 Words (Stop Words Removed)") +
    ylab("Frequency") +
    ylim(0,max(allbar$freq)) +
    theme_minimal()
  show(p)
}

shinyServer(function(input, output) {
  output$word_cloud <- renderPlot(
      {
        word_cloud <- create_wordcloud(sotu_df, input$numWords)
        print(word_cloud)
      }
    )
  output$bar_plot <- renderPlot(
      {
       bar_plot <- create_barplot(allbar, input$which_book)
       print(bar_plot)
      }
    )
})










