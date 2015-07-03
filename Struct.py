class Struct(object):
    __flds=[]
    @classmethod
    def setFields(cls,flds):
        cls.__flds=flds
        return cls
    def __init__(self, recs=None):
        if recs:
            self.__dict__.update(recs)
    def __str__(self):
        return "<"+", ".join(["%s:%s" % (x,self.__dict__[x]) for x in self.__flds])+">"

