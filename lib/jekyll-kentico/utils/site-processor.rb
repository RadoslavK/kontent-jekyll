require_relative '../models/kentico-page'

class SiteProcessor
  def initialize(site)
    @site = site
  end

  def process_pages_data(pages_data_by_collection)
    pages_data_by_collection.each do |collection_name, pages_data|
      @site.pages += pages_data.map(&method(:to_kentico_page))

      next unless collection_name && !collection_name.empty?

      collection = Jekyll::Collection.new @site, collection_name
      @site.collections[collection_name] = collection

      pages_data.each do |page_data|
        path = page_data.filename
        page = create_document path, @site, collection, page_data
        collection.docs << page
      end
    end
  end

  def process_posts_data(posts_data)
    posts = @site.collections['posts']

    posts_data.each do |post_data|
      path = File.join @site.source, '_posts', post_data.filename
      post = create_document path, @site, posts, post_data
      posts.docs << post
    end
  end

  def process_taxonomies(taxonomies)
    @site.data['taxonomies'] = taxonomies if taxonomies
  end

  def process_data(data_items)
    @site.data.merge! data_items
  end
private
  def to_kentico_page(page_data)
    Jekyll::KenticoPage.new(@site, page_data)
  end

  def populate_collection(collection_name, documents_data, dir)
    collection =
      if @site.collections.key? collection_name
        @site.collections[collection_name]
      else
        collection = Jekyll::Collection.new @site, collection_name
        @site.collections[collection_name] = collection
      end

    documents_data.each do |document_data|
      path = File.join dir, document_data.filename
      document = create_document path, @site, collection, document_data
      collection.docs << document
    end
  end

  def create_document(path, site, collection, source)
    post = Jekyll::Document.new path, site: site, collection: collection
    post.content = source.content
    post.data.merge! source.data
    post
  end
end