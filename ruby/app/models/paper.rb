class Paper < ActiveRecord::Base

  include HTTParty
  debug_output $stdout
  #database = "pubmed"

  @search_url = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi'
  @fetch_url  = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi'

  # esearch.fcgi?
  
  def self.search_remote(query="")

    
    options = default_options.merge({query: {term: query}})
    r = get(@search_url, options)

    @papers = r.body
    
  end


  def self.read_remote(doc_id)

    params = {query: {db: "pubmed", id: doc_id }}

    r = get(@fetch_url, params)
    
  end


  def download!
    # 
  end
  
  def self.default_options
    {
      query: {
        db: 'pubmed'
      }
    }
  end
  
end
