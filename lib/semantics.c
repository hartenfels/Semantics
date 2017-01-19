#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <errno.h>
#include <jni.h>


#define NOTHING

#define BOOLIFY(EXPR) ((EXPR) ? 1 : 0)

#define J_FIND_CLASS(cls, name, retval) \
    if (!(cls = (*env)->FindClass(env, name))) { \
        fprintf(stderr, "Can't find class '%s'\n", name); \
        return retval; \
    }

#define J_FIND_METHOD(meth, cls, name, args, retval) \
    if (!(meth = (*env)->GetMethodID(env, cls, name, args))) { \
        fprintf(stderr, "Can't find method '%s'\n", name); \
        return retval; \
    }

#define J_GET_OBJECT_CLASS(cls, obj, retval) \
    if (!obj || !(cls = (*env)->GetObjectClass(env, obj))) { \
        fprintf(stderr, "Can't get object class for '%p'\n", (void *)obj); \
        return retval; \
    }


#define D_CALL(RETTYPE, NAME, CALL) \
    static RETTYPE NAME (jobject obj, const char *name, const char *sig, ...) \
    { \
        va_list   args; \
        jclass    cls; \
        jmethodID mid; \
        RETTYPE   ret; \
        \
        J_GET_OBJECT_CLASS(cls, obj, 0); \
        J_FIND_METHOD(mid, cls, name, sig, 0); \
        \
        va_start(args, sig); \
        ret = (*env)-> CALL (env, obj, mid, args); \
        va_end(args); \
        \
        return ret; \
    }

#define D_ARGS const char *name, const char *sig


static JavaVM *jvm = NULL;
static JNIEnv *env = NULL;


int have_jvm(void)
{
    return BOOLIFY(env);
}


int init_jvm(char *optv[], int optc, int *error)
{
    JavaVMInitArgs args;
    JavaVMOption  *options;
    int            i, status;

    if (!(options = calloc(optc, sizeof *options))) {
        *error = errno;
        return 1;
    }

    for (i = 0; i < optc; ++i) {
        options[i].optionString = optv[i];
    }

    args.version            = JNI_VERSION_1_8;
    args.nOptions           = optc;
    args.options            = options;
    args.ignoreUnrecognized = 0;

    status = JNI_CreateJavaVM(&jvm, (void **)&env, &args);

    free(options);

    if (status < 0 || !env) {
        *error = status;
        return 2;
    }

    return 0;
}


jthrowable check_exception(void)
{
    jthrowable ex = (*env)->ExceptionOccurred(env);
    (*env)->ExceptionClear(env);
    return ex;
}


jobject root(jobject obj)
{
    return (*env)->NewGlobalRef(env, obj);
}

void unroot(jobject obj)
{
    (*env)->DeleteGlobalRef(env, obj);
}


jstring s2j(const jchar *str, unsigned int len)
{
    return (*env)->NewString(env, str, len);
}


void j2s(jstring str, jchar *(*gimme_buf)(unsigned int))
{
    jsize        len;
    const jchar *chars;

    len   = (*env)->GetStringLength(env, str);
    chars = (*env)->GetStringChars(env, str, JNI_FALSE);

    memcpy(gimme_buf(len), chars, len * sizeof(*chars));

    (*env)->ReleaseStringChars(env, str, chars);
}


jobject a2j(const char *clsname, jobject *objs, unsigned int len)
{
    jclass       cls;
    jobjectArray arr;
    unsigned int i;

    J_FIND_CLASS(cls, clsname, NULL);

    if (!(arr = (*env)->NewObjectArray(env, len, cls, NULL))) {
        return NULL;
    }

    for (i = 0; i < len; ++i) {
        (*env)->SetObjectArrayElement(env, arr, i, objs[i]);

        if ((*env)->ExceptionOccurred(env)) {
            return NULL;
        }
    }

    return arr;
}


void j2a(jarray arr, void (*callback)(jobject))
{
    jsize i, len;

    for (i = 0, len = (*env)->GetArrayLength(env, arr); i < len; ++i) {
        callback((*env)->GetObjectArrayElement(env, arr, i));
    }
}


jobject init_knowbase(jstring str)
{
    jclass    cls;
    jmethodID mid;

    J_FIND_CLASS(cls, "KnowBase", NULL);
    J_FIND_METHOD(mid, cls, "<init>", "(Ljava/lang/String;)V", NULL);

    return (*env)->NewObject(env, cls, mid, str);
}


D_CALL(jboolean, call_b, CallBooleanMethodV)

int b_o(D_ARGS, jobject obj, jobject arg1)
{
    return BOOLIFY(call_b(obj, name, sig, arg1));
}


D_CALL(jobject, call_o, CallObjectMethodV)

jobject o(D_ARGS, jobject obj)
{
    return call_o(obj, name, sig);
}

jobject o_o(D_ARGS, jobject obj, jobject arg1)
{
    return call_o(obj, name, sig, arg1);
}

jobject o_oo(D_ARGS, jobject obj, jobject arg1, jobject arg2)
{
    return call_o(obj, name, sig, arg1);
}
