#include <QObject>

#include <MauiKit4/Core/mauilist.h>

class NotesSyncer;
class Notes : public MauiList
{
    Q_OBJECT

public:
    explicit Notes(QObject *parent = nullptr);
    const FMH::MODEL_LIST &items() const override final;
    void componentComplete() override final;

private:
    NotesSyncer *syncer;

    FMH::MODEL_LIST notes;
    QVariantMap m_account;

    void setList();
    void sortList();

    void appendNote(FMH::MODEL note);

public Q_SLOTS:
    bool insert(const QVariantMap &note);
    bool update(const QVariantMap &data, const int &index);
    bool remove(const int &index);
    int indexOfNote(const QUrl &url);

    int indexOfName(const QString &query);

};
