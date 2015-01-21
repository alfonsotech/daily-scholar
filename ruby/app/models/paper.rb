class Paper < ActiveRecord::Base

  require 'nokogiri'
  include HTTParty
  debug_output $stdout
  #database = "pubmed"

  @search_url  = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi'
  @fetch_url   = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi'
  @doi_url     = 'http://dx.doi.org'

  # Params for destructuring Pubmed XML Response
  @base_xpath     = '//PubmedArticleSet/PubmedArticle/MedlineCitation/Article'
  @journal_xpath  = @base_xpath + '/Journal'
  @title_xpath    = @base_xpath + '/ArticleTitle'
  @abstract_xpath = @base_xpath + '/Abstract/AbstractText'
  @doi_xpath      = @base_xpath + '/ELocationID'
  
  # author information is deeply nested and must be interated over (it's a list)
  @author_base  = @base_xpath + '/AuthorList/Author'
  @author_lname = @author_base + '/LastName'
  @author_fname = @author_base + '/ForeName'
  @author_intls = @author_base + '/Initials'
  @author_aff   = @author_base + '/AffiliationInfo/Affiliation'
  
  # Can I do this? Will Ruby let me do this??? IDK...
  # Having the xpaths in a lookup table of sorts would be much easier and save memory
  #@xpaths = {
  #  base: '//PubmedArticleSet/PubmedArticle/MedlineCitation/Article',
  #  journal: @xpaths['base'] + '/Journal',
  #  title: @xpaths['base'] + '/ArticleTitle',
  #  abstract: @xpaths['base'] + '/Abstract/AbstractText',
  #  author: {
  #    base: @xpaths['base'] + '/AuthorList/Author',
  #    lname: @xpaths['author']['base'] + '/LastName',
  #    fname: @xpaths['author']['base'] + '/ForeName',
  #    initials: @xpaths['author']['base'] + '/Initials',
  #    affiliation: @xpaths['author']['base'] + '/AffiliationInfo/Affiliation'
  #  }
  #}

  @default_options = {
    query: {
      db: 'pubmed',
      retmode: 'xml'
    }
  }
  
  def self.search_remote(term="")

    @papers = {}
    
    options = {query: @default_options[:query].merge({term: term})}
    puts options
    
    r = get('http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi', options)
    

    # An array of paper IDs from the search result
    pids = r["eSearchResult"]["IdList"]["Id"]
    puts pids

    pids.each do |pid|
      # get the titles and abstracts of each id
      params = @default_options[:query].merge({id: pid})
      s = get(@fetch_url, params)
      puts s.body
      @papers[pid] = {
        title: Nokogiri::XML(s.body).at_xpath(@title_xpath).content,
        abstract: Nokogiri::XML(s.body).at_xpath(@abstract_xpath).content,
        link: @article_url + Nokogiri::XML(s.body).at_xpath(@doi_xpath).content
      }
    end
  end


  def self.read_remote(doc_id)

    params = default_options.merge({query: {id: doc_id }})

    r = get(@fetch_url, params)
    
  end


  def download!
    # 
  end
  
  def self.default_options
    {
      query: {
        db: 'pubmed',
        retmode: 'xml'
      }
    }
  end
  
end
