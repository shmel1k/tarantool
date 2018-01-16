/*
 * Tarantool interface, external linkage.
 *
 * Note: functions with "sqlite3" prefix in their names become static in
 * amalgamated build with the help of a custom preprocessor tool,
 * that's why we are using a weird naming schema.
 */

#include <stdint.h>

/*
 * Tarantool system spaces.
 */
#define TARANTOOL_SYS_SEQUENCE_NAME "_SEQUENCE"
#define TARANTOOL_SYS_SPACE_SEQUENCE_NAME "_SPACE_SEQUENCE"
#define TARANTOOL_SYS_SCHEMA_NAME  "_SCHEMA"
#define TARANTOOL_SYS_SPACE_NAME   "_SPACE"
#define TARANTOOL_SYS_INDEX_NAME   "_INDEX"
#define TARANTOOL_SYS_TRIGGER_NAME "_TRIGGER"
#define TARANTOOL_SYS_TRUNCATE_NAME "_TRUNCATE"

/* Max space id seen so far. */
#define TARANTOOL_SYS_SCHEMA_MAXID_KEY "max_id"

/*
 * SQLite uses the root page number to identify a Table or Index BTree.
 * We switched it to using Tarantool spaces and indices instead of the
 * BTrees. Hence the functions to encode index and space id in
 * a page number.
 */
#define SQLITE_PAGENO_FROM_SPACEID_AND_INDEXID(spaceid, iid) \
  (((unsigned)(spaceid) << 10) | (iid))

#define SQLITE_PAGENO_TO_SPACEID(pgno) \
  ((unsigned)(pgno) >> 10)

#define SQLITE_PAGENO_TO_INDEXID(pgno) \
  ((pgno) & 1023)

/* Load database schema from Tarantool. */
void sqlLoadSchema(InitData *init);

/* Misc */
const char *tarantoolErrorMessage();

/* Storage interface. */
const void *sqlPayloadFetch(BtCursor *pCur, u32 *pAmt);
int sqlMoveToUnpacked(BtCursor *pCur, UnpackedRecord *pIdxKey, int *pRes);

/**
 * Try to get a current tuple field using its field map.
 * @param pCur Btree cursor holding a tuple.
 * @param fieldno Number of a field to get.
 * @param[out] field_size Result field size.
 * @retval not NULL MessagePack field.
 * @retval     NULL Can not use field_map - it does not contain
 *         offset to @a fieldno.
 */
const void *sqlTupleColumnFast(BtCursor *pCur, u32 fieldno, u32 *field_size);

/* Cursor positioning interface. */
int sqlCursorCreate(BtCursor *pCur);
int sqlCursorClose(BtCursor *pCur);
int sqlCursorFirst(BtCursor *pCur, int *pRes);
int sqlCursorLast(BtCursor *pCur, int *pRes);
int sqlCursorNext(BtCursor *pCur, int *pRes);
int sqlCursorPrevious(BtCursor *pCur, int *pRes);

/* SQL interface. */
int sqlCount(BtCursor *pCur, i64 *pnEntry);
int sqlInsert(BtCursor *pCur, const BtreePayload *pX);
int sqlDelete(BtCursor *pCur);
int sqlClearTable(BtCursor *pCur);

/* Rename table pTab with zNewName by inserting new tuple to _space.
 * SQL statement, which creates table with new name is saved in pzSqlStmt.
 */
int tarantoolSqlite3RenameTable(int iTab, const char *zNewName, char *zSqlStmt,
				uint32_t *pSqlStmtLen);

/* Alter trigger statement after rename table. */
int tarantoolSqlite3RenameTrigger(const char *zTriggerName,
				  const char *zOldName, const char *zNewName);

/* Alter create table statement of child foreign key table by
 * replacing parent table name in create table statement.*/
int tarantoolSqlite3RenameParentTable(int iTab, const char *zOldParentName,
				      const char *zNewParentName);

/* Interface for ephemeral tables. */
int sqlEphemeralSpaceCreate(BtCursor *pCur, uint32_t filed_count,
			    struct coll *aColl);
int sqlEphemeralSpaceDrop(BtCursor *pCur);

/* Compare against the index key under a cursor -
 * the key may span non-adjacent fields in a random order,
 * ex: [4]-[1]-[2]
 */
int sqlIdxKeyCompare(BtCursor *pCur, UnpackedRecord *pUnpacked, int *res);

/*
 * The function assumes the cursor is open on _schema.
 * Increment max_id and store updated tuple in the cursor
 * object.
 */
int sqlIncrementMaxid(BtCursor *pCur);

/*
 * Render "format" array for _space entry.
 * Returns result size.
 * If buf==NULL estimate result size.
 */
int sqlMakeTableFormat(Table *pTable, void *buf);

/*
 * Format "opts" dictionary for _space entry.
 * Returns result size.
 * If buf==NULL estimate result size.
 */
int sqlMakeTableOpts(Table *pTable, const char *zSql, void *buf);

/*
 * Format "parts" array for _index entry.
 * Returns result size.
 * If buf==NULL estimate result size.
 */
int sqlMakeIdxParts(Index *index, void *buf);

/*
 * Format "opts" dictionary for _index entry.
 * Returns result size.
 * If buf==NULL estimate result size.
 */
int sqlMakeIdxOpts(Index *index, const char *zSql, void *buf);

/*
 * Fetch maximum value from ineger column number `fieldno` of space_id/index_id
 * Return 0 on success, -1 otherwise
 */
int sqlGetMaxId(BtCursor *pCur, uint32_t index_id, uint32_t fieldno,
		uint64_t *max_id);
