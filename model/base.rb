module Model
  class Base
    def all
      repo
    end

    def first
      all[all.keys[0]]
    end

    def find(id)
      repo[id.to_sym]
    end

    def sample
      all[all.keys.sample]
    end
  end
end
