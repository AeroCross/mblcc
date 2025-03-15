module Model
  class Base
    def all
      repo
    end

    def first
      all[all.keys[0]]
    end

    def sample
      all[all.keys.sample]
    end
  end
end
